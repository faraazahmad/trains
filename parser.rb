require "rubocop-ast"
require "parser"

class MigrationParser < Parser::AST::Processor
  include RuboCop::AST::Traversal

  attr_reader :is_migration
  #def on_sym(node)
  #  puts "I found a symbol! #{node.value}"
  #  p node
  #end
  
  def initialize
    @is_class = false
    @is_migration = false
    @class_name = nil

    @scope = {
      class: nil, 
      method: nil,
      send: nil
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
    puts @scope
  end

  def on_send(node)
    #if @scope[:method] == :change
     # puts node
    #end
    # puts "at send node. scope = #{@scope}"
  end
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


