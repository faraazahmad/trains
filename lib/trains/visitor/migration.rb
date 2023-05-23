require 'yaml'

module Trains
  module Visitor
    # Visitor that parses DB migration and associates them with Rails models
    class Migration < Base
      def_node_matcher :send_node?, '(send nil? ...)'
      attr_reader :is_migration, :model

      def initialize
        @model = nil
        @table_modifier = nil
        @table_name = nil
        @is_class = false
        @is_migration = false
        @class_name = nil
        @fields = []

        @scope = { class: nil, method: nil, send: nil }
      end

      def on_class(node)
        unless node.parent_class.source.include? 'ActiveRecord::Migration'
          return
        end

        @migration_class = node.children.first.source
        @migration_version = extract_version(node.parent_class.source)

        process_node(node.body)
      end

      def result
        DTO::Migration.new(
          table_name: @table_name,
          modifier: @table_modifier,
          fields: @fields,
          version: @migration_version
        )
      end

      private

      def extract_version(class_const)
        match = class_const.match(/\d+.\d+/)
        return nil if match.nil?

        match.to_s.to_f
      end

      def process_node(node)
        return unless node.def_type?

        process_def_node(node)
      end

      def process_def_node(node)
        allowed_method_names = %i[change up down]
        allowed_table_modifiers = %i[
          create_table
          change_table
          update_column
          add_column
          remove_column
          change_column
          add_index
        ]
        column_modifiers = %i[
          add_column
          change_column
          remove_column
        ]

        method_name = node.method_name
        return unless allowed_method_names.include? method_name
        return if node.body.nil?

        table_modifier =
          # if table modifier is a one-liner method call
          if node.body.children[0].nil?
            node.body.children[1]
          elsif node.body.children[0].block_type?
            # if table modifier is in a block
            node.body.children[0].method_name
          elsif node.body.children[0].send_type?
            node.body.children[0].method_name
          end
        return unless allowed_table_modifiers.include? table_modifier

        @table_modifier = table_modifier

        node.each_descendant(:send) do |send_node|
          if allowed_table_modifiers.include?(send_node.method_name)
            raw_table_name = send_node.arguments[0]
            @table_name = raw_table_name.value.to_s.singularize.camelize
            if column_modifiers.include?(send_node.method_name)
              @fields.append(DTO::Field.new(send_node.arguments[1].value,
                                            send_node.arguments[2]&.value))
            end

            next
          end

          next if allowed_table_modifiers.include?(send_node.method_name)

          parse_migration_field(send_node)
        end
      end

      def parse_migration_field(node)
        if node.children[1] == :timestamps
          @fields.append(DTO::Field.new(:created_at, :datetime))
          @fields.append(DTO::Field.new(:updated_at, :datetime))
          return
        end

        type = node.children[1]
        value = node.children[2].value unless node.children[2].hash_type?
        @fields.append(DTO::Field.new(value, type))
      end
    end
  end
end
