require 'yaml'

module Trains
  module Visitor
    class Migration < Base
      def_node_matcher :send_node?, '(send nil? ...)'
      attr_reader :is_migration, :model

      def initialize
        @model = nil
        @table_name = nil
        @is_class = false
        @is_migration = false
        @class_name = nil
        @fields = Set.new

        @scope = { class: nil, method: nil, send: nil }
      end

      def on_class(node)
        return unless node.parent_class.source.include? 'ActiveRecord::Migration'

        @migration_class = node.children.first.source
        @migration_version = extract_version(node.parent_class.source)

        process_node(node.body)
      end

      def extract_version(class_const)
        match = class_const.match(/\d+.\d+/)
        return nil if match.nil?

        match.to_s.to_f
      end

      def process_node(node)
        process_def_node(node) if node.def_type?
      end

      def process_def_node(node)
        allowed_method_names = %i[change up down]
        allowed_table_modifiers = %i[create_table update_column]

        method_name = node.method_name
        return unless allowed_method_names.include? method_name

        table_modifier = node.body.children[0].method_name
        return unless allowed_table_modifiers.include? table_modifier

        raw_table_name = node.body.children[0].children[0].children[2].value.to_s
        @table_name = raw_table_name.singularize.camelize

        node.body.children[0].children[2].each_child_node do |child|
          process_migration_field(child)
        end
      end

      def process_migration_field(node)
        return unless node.send_type?

        if node.children.count < 3
          if node.children[1] == :timestamps
            @fields.add(DTO::Field.new(:datetime, :created_at))
            @fields.add(DTO::Field.new(:datetime, :updated_at))
          end
        elsif node.children.count >= 3
          type = node.children[1]
          value = node.children[2].value
          @fields.add(DTO::Field.new(type, value))
        end
      end

      def result
        DTO::Model.new(@table_name, Set[*@fields], @migration_version)
      end
    end
  end
end
