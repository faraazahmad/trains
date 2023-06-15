require 'yaml'

module Trains
  module Visitor
    # Visitor that parses DB migration and associates them with Rails models
    class Migration < Base
      include Utils::Args

      def_node_matcher :send_node?, '(send nil? ...)'
      attr_reader :is_migration, :model, :result

      ALLOWED_METHOD_NAMES = %i[change up].freeze
      ALLOWED_TABLE_MODIFIERS = %i[
        create_table
        create_join_table
        change_table
        safety_assured
        update_column
      ].freeze
      COLUMN_MODIFIERS = %i[
        add_column
        change_column
        add_reference
        remove_column
      ].freeze

      # skipcq: RB-LI1087
      def initialize
        @result = []
        @migration_class = nil
        @migration_version = nil
      end

      def on_class(node)
        unless node.parent_class.source.include? 'ActiveRecord::Migration'
          return
        end

        @migration_class = node.children.first.source
        @migration_version = extract_version(node.parent_class.source)

        node.each_descendant(:def) do |child_node|
          next if child_node.body.nil?
          next unless ALLOWED_METHOD_NAMES.include?(child_node.method_name)

          process_migration(child_node)
        end
      end

      private

      def extract_version(class_const)
        match = class_const.match(/\d+.\d+/)
        return nil if match.nil?

        match.to_s.to_f
      end

      def process_migration(node)
        case node.body.type
        when :send
          @result << parse_one_liner_migration(node.body)
        when :begin
          if node.body.children.map(&:type).include?(:block)
            migration = parse_block_migration(node.body)
            @result = [*@result, *migration] if migration
          else
            node.body.each_descendant(:send) do |send_node|
              migration = parse_one_liner_migration(send_node)
              @result << migration if migration
            end
          end
        when :block
          @result = [*@result, *parse_block_migration(node)]
        when :if, :until
          puts "Using unsupported logic within Rails migration: #{node.body.type}"
        else
          puts "[process_migration]: Unable to parse the following node:"
          # skipcq: RB-RB-LI1008
          pp node
        end
      end

      def parse_one_liner_migration(node)
        return unless COLUMN_MODIFIERS.include?(node.method_name)

        arguments = node.arguments
        table_name = arguments[0].value.to_s.singularize.camelize
        column_name = arguments[1].value

        if node.method_name == :add_reference
          type = :bigint
          column_name = "#{arguments[1].value}_id".to_sym
        else
          type = arguments[2].value unless node.method_name == :remove_column
        end

        DTO::Migration.new(
          table_name,
          node.method_name,
          [DTO::Field.new(column_name, type)],
          @migration_version
        )
      end

      def parse_block_migration(node)
        migrations = []
        # Visit every send_node that performs DDL tasks
        node.children.each do |ddl_node|
          next if ddl_node.is_a?(Symbol)

          fields = []
          if ddl_node.is_a?(RuboCop::AST::BlockNode)
            next unless ALLOWED_TABLE_MODIFIERS.include?(ddl_node.method_name)

            if ddl_node.method_name == :safety_assured
              ddl_node.each_descendant(:send) do |send_node|
                migrations = [*migrations,
                              *parse_one_liner_migration(send_node)]
              end

              next
            end

            table_name = ddl_node.send_node.arguments[0].value.to_s.singularize.camelize
            case ddl_node.method_name
            when :create_join_table
              field_one = ddl_node.send_node.arguments[0].value.to_s
              field_two = ddl_node.send_node.arguments[1].value.to_s

              table_name = field_one.camelize + field_two.camelize

              fields << DTO::Field.new("#{field_one.singularize}_id".to_sym,
                                       :bigint)
              fields << DTO::Field.new("#{field_two.singularize}_id".to_sym,
                                       :bigint)
            when :create_table
              fields << DTO::Field.new(:id, :bigint)
            end

            ddl_node.body.each_descendant(:send) do |send_node|
              fields = [*fields, *parse_migration_field(send_node)]
            end

            migrations << DTO::Migration.new(
              table_name,
              ddl_node.method_name,
              fields,
              @migration_version
            )
          elsif ddl_node.is_a?(RuboCop::AST::SendNode)
            migrations = [*migrations, *parse_one_liner_migration(ddl_node)]
          end
        end

        migrations
      end

      def parse_migration_field(node)
        fields = []
        # t.timestamps
        if node.children[1] == :timestamps
          fields << DTO::Field.new(:created_at, :datetime)
          fields << DTO::Field.new(:updated_at, :datetime)
          return fields
        end

        return [] if node.arguments.nil? || node.arguments.empty?

        # method used to create the column
        # string is the col_method in t.string
        col_method = node.children[1]
        case col_method
        when :column
          # t.column col_name, col_type
          type = node.children[3].value
          value = node.children[2].value
          fields << DTO::Field.new(value, type)
        when :references, :belongs_to
          # t.references
          type = :bigint
          value = "#{node.children[2].value}_id".to_sym
          fields << DTO::Field.new(value, type)
        when :index
        else
          # t.string, t.integer etc.
          type = node.children[1]
          value = parse_args(node.children[2])
          fields << DTO::Field.new(value, type)
        end

        fields
      end
    end
  end
end
