require "yaml"

module Trains
  module Visitor
    class Migration < Base
      def_node_matcher :send_node?, "(send nil? ...)"
      attr_reader :is_migration, :model

      def initialize
        @model = nil
        @is_class = false
        @is_migration = false
        @class_name = nil

        @scope = { class: nil, method: nil, send: nil }
      end

      def on_class(node)
        # binding.irb
        if node.parent_class.source.include? "ActiveRecord::Migration"
          @migration_class = node.children.first.source
          @migration_version = extract_version(node.parent_class.source)
        end
        # @is_class = true
        # @scope[:class] = node.identifier.const_name
        # const_ref = node.parent_class.child_nodes[0]

        # inherited_class = const_ref.const_name
        # @is_migration = true if inherited_class == "ActiveRecord::Migration"
      end

      def extract_version(class_const)
        match = class_const.match(/\d+.\d+/)
        return nil if match.nil?

        match.to_s.to_f
      end
      # def on_def(node)
      #   method_name = node.method_name
      #   @scope[:method] = method_name
      #   @is_migration = false unless %w[change up down].include? method_name
      #   parse_migration_method node
      # end

      # def parse_migration_method(node)
      #   node.body.each_node do |child_node|
      #     pp child_node if send_node? child_node
      #   end
      #   orm_method_call = node.body.block.send_node

      #   return unless orm_method_call.method_name == :create_table

      #   @model.name = orm_method_call.first_argument.value
      #   method_body = node.body.body
      #   fields = nil

      #   fields =
      #     case method_body.type.to_sym
      #     when :send
      #       parse_field method_body
      #     when :begin
      #       method_body.each_child_node.map do |child_node|
      #         parse_field child_node
      #       end
      #     end

      #   fields.each do |field|
      #     if field.is_a? Array
      #       field.each { |f| @model.fields.append f }
      #     elsif field.is_a? Hash
      #       @model.fields.append field
      #     else
      #       debug "unknown field type: #{field}"
      #     end
      #   end
      # end

      # def parse_field(child_node)
      #   case child_node.method_name
      #   when :column
      #     {
      #       column: child_node.arguments[0].value,
      #       type: child_node.arguments[-1].value
      #     }
      #   when :references
      #     { column: child_node.arguments[0].value, type: :reference }
      #   when :integer
      #     { column: child_node.arguments[0].value, type: :integer }
      #   when :string
      #     { column: child_node.arguments[0].value, type: :string }
      #   when :timestamps
      #     [
      #       { column: :created_at, type: :datetime },
      #       { column: :updated_at, type: :datetime }
      #     ]
      #   else
      #     debug "Unknown node type #{child_node}"
      #     nil
      #   end
      # end

      def result
        DTO::Model.new(@migration_class, Set.new, @migration_version)
      end
    end
  end
end

# class MigrationVisitor < AST::Visitor
#   def initialize(file)
#     @file = file
#     @source = ProcessedSource.new(File.read(file), file)
#     @migration_class = nil
#     @migration_version = nil
#     @migration_name = nil
#   end

#   def visit_class(node)
#     # Check if the class is a migration class
#     if node.superclass.source == "ActiveRecord::Migration"
#       @migration_class = node.children.first.source
#       @migration_version = extract_version(node.children.first.source)
#     end

#     # Visit each node in the class body
#     node.children[1].children.each do |child|
#       visit(child)
#     end
#   end

#   def visit_def(node)
#     # Check if the method is a migration method (up or down)
#     if node.children.first.source == "up" || node.children.first.source == "down"
#       @migration_name = node.children.first.source
#     end
#   end

#   def extract_version(class_name)
#     class_name.match(/\d{14}/)[0]
#   end

#   def migration_class
#     @migration_class
#   end

#   def migration_version
#     @migration_version
#   end

#   def migration_name
#     @migration_name
#   end
# end
