require "yaml"

module Trains
  module Visitor
    class Migration < Base
      attr_reader :is_migration, :model

      def initialize
        @model = Model.new
        @is_class = false
        @is_migration = false
        @class_name = nil

        @scope = { class: nil, method: nil, send: nil }
      end

      def on_class(node)
        @is_class = true
        @scope[:class] = node.identifier.const_name
        const_ref = node.parent_class.child_nodes[0]

        inherited_class = const_ref.const_name
        @is_migration = true if inherited_class == "ActiveRecord::Migration"
      end

      def on_def(node)
        method_name = node.method_name
        @scope[:method] = method_name
        @is_migration = false unless %w[change up down].include? method_name
        parse_migration_method node
      end

      def parse_migration_method(node)
        orm_method_call = node.body.send_node

        return unless orm_method_call.method_name == :create_table

        @model.name = orm_method_call.first_argument.value
        method_body = node.body.body
        fields = nil

        fields =
          case method_body.type.to_sym
          when :send
            parse_field method_body
          when :begin
            method_body.each_child_node.map do |child_node|
              parse_field child_node
            end
          end

        fields.each do |field|
          if field.is_a? Array
            field.each { |f| @model.fields.append f }
          elsif field.is_a? Hash
            @model.fields.append field
          else
            debug "unknown field type: #{field}"
          end
        end
      end

      def parse_field(child_node)
        case child_node.method_name
        when :column
          {
            column: child_node.arguments[0].value,
            type: child_node.arguments[-1].value
          }
        when :references
          { column: child_node.arguments[0].value, type: :reference }
        when :integer
          { column: child_node.arguments[0].value, type: :integer }
        when :string
          { column: child_node.arguments[0].value, type: :string }
        when :timestamps
          [
            { column: :created_at, type: :datetime },
            { column: :updated_at, type: :datetime }
          ]
        else
          debug "Unknown node type #{child_node}"
          nil
        end
      end

      def result
        @model
      end
    end
  end
end
