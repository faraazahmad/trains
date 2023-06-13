require 'yaml'

module Trains
  module Visitor
    # Visitor that parses DB migration and associates them with Rails models
    class Migration < Base
      def_node_matcher :send_node?, '(send nil? ...)'
      attr_reader :is_migration, :model, :result

      ALLOWED_METHOD_NAMES = %i[change up down].freeze
      ALLOWED_TABLE_MODIFIERS = %i[
        create_table
        change_table
        update_column
        add_index
      ].freeze
      COLUMN_MODIFIERS = %i[
        add_column
        change_column
        remove_column
      ].freeze

      def initialize
        @model = nil
        @table_modifier = nil
        @table_name = nil
        @is_class = false
        @is_migration = false
        @class_name = nil
        @fields = []
        @result = []

        @scope = { class: nil, method: nil, send: nil }
      end

      def on_class(node)
        unless node.parent_class.source.include? 'ActiveRecord::Migration'
          return
        end

        @migration_class = node.children.first.source
        @migration_version = extract_version(node.parent_class.source)

        process_def_node(node.body)
      end

      private

      def extract_version(class_const)
        match = class_const.match(/\d+.\d+/)
        return nil if match.nil?

        match.to_s.to_f
      end

      def process_def_node(node)
        return unless node.def_type?

        method_name = node.method_name
        unless ALLOWED_METHOD_NAMES.include?(method_name) || COLUMN_MODIFIERS.include?(method_name)
          return
        end
        return if node.body.nil?

        case node.body.type
        when :send
          @result << parse_one_liner_migration(node.body)
        when :begin
          if node.body.children.map(&:type).include?(:block)
            migration = parse_block_migration(node)
            @result = [*@result, *migration] if migration
          else
            node.body.each_descendant(:send) do |send_node|
              migration = parse_one_liner_migration(send_node)
              @result << migration if migration
            end
          end
        when :block
          @result = [*@result, *parse_block_migration(node)]
        else
          pp node
        end
      end

      def parse_one_liner_migration(node)
        return unless COLUMN_MODIFIERS.include?(node.method_name)

        arguments = node.arguments
        table_name = arguments[0].value.to_s.singularize.camelize
        column_name = arguments[1].value
        type = arguments[2].value unless node.method_name == :remove_column

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
        node.each_descendant do |ddl_node|
          fields = []

          if ddl_node.block_type?
            next unless ALLOWED_TABLE_MODIFIERS.include?(ddl_node.method_name)

            table_name = ddl_node.send_node.arguments[0].value.to_s.singularize.camelize
            ddl_node.body.each_descendant(:send) do |send_node|
              fields = [*fields, *parse_migration_field(send_node)]
            end

            migrations << DTO::Migration.new(
              table_name,
              ddl_node.method_name,
              fields,
              @migration_version
            )
          elsif ddl_node.send_type?
            migrations = [*migrations, *parse_one_liner_migration(ddl_node)]
          end
        end

        migrations
      end

      def parse_migration_field(node)
        fields = []
        if node.children[1] == :timestamps
          fields << DTO::Field.new(:created_at, :datetime)
          fields << DTO::Field.new(:updated_at, :datetime)
          return fields
        end

        return [] if node.arguments.nil? || node.arguments.empty?

        type = node.children[1]
        value = node.children[2].value unless node.children[2].hash_type?
        fields << DTO::Field.new(value, type)

        fields
      end
    end
  end
end
