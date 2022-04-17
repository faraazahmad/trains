require "rubocop-ast"
require "parser"
require "yaml"

class MigrationParser < Parser::AST::Processor
  include RuboCop::AST::Traversal

  attr_reader :is_migration, :model_name, :model_fields
  
  def initialize
    @is_class = false
    @is_migration = false
    @class_name = nil
    @model_name = nil
    @model_fields = []

    @scope = {
      class: nil, 
      method: nil,
      send: nil,
      fields: []
    }
  end

  def on_class(node)
    @is_class = true
    @scope[:class] = node.identifier.const_name
    const_ref = node.parent_class.child_nodes[0]

    inherited_class = const_ref.const_name
    if inherited_class == 'ActiveRecord::Migration'
      @is_migration = true
    end
  end

  def on_def(node)
    @scope[:method] = node.method_name
    unless %w(change up down).include? node.method_name
      @is_migration = false
    end
    # puts @scope
    parse_migration_method node
  end

  def parse_migration_method(node)
    orm_method_call = node.body.send_node
    return unless orm_method_call.method_name == :create_table
    @model_name = orm_method_call.first_argument.value
    body = nil
    field = nil
    body = node.body.body if node.body.block_type?
    
    body.each_child_node do |node|
      field = case node.method_name
      when :column
        { column: node.arguments[0].value, type: node.arguments[-1].value }
      when :integer
        { column: node.arguments[0].value, type: :integer }
      when :timestamps
        [
          { column: :created_at, type: :datetime },
          { column: :updated_at, type: :datetime }
        ]
      else nil
      end

      if field.is_a? Array
          field.each { |f| @model_fields.append f }
      elsif field.is_a? Hash
          @model_fields.append field
      else
          raise "unknown field type: #{field}"
      end

      # @model_fields.append field unless field.nil?
    end

    # pp @model_fields
   end
=begin
  def on_send(node)
    if @scope[:method] == :change
      p node.block_node if node.block_node
    end
    # puts "at send node. scope = #{@scope}"
  end
=end
end

class MyParser
  def initialize(ast)
    @ast = ast
  end

  def analyse
    @ast.child_nodes[0].class_type?
  end
end

file_path = ARGV[0]
file = File.open(File.expand_path(file_path))
code = file.read
file.close

source = RuboCop::AST::ProcessedSource.new(code, 3.0)
migration_parser = MigrationParser.new
# ast = source.ast
source.ast.each_node { |node| migration_parser.process node }
#parser = MyParser.new(ast)
#p parser.analyse
#puts migration_parser.model_name
#puts migration_parser.scope

puts migration_parser.to_yaml
