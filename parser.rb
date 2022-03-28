require "rubocop-ast"
require "parser"

class MigrationParser < Parser::AST::Processor
  include RuboCop::AST::Traversal

  #def on_sym(node)
  #  puts "I found a symbol! #{node.value}"
  #  p node
  #end
  
  def initialize
    @is_class = false
    @is_migration = false
    @class_name = nil
  end

  def on_class(node)
    @is_class = true
    const_ref = node.parent_class.child_nodes[0]

    inherited_classes = const_ref.const_name.split('::')
    if inherited_classes[0] == 'ActiveRecord' && inherited_classes[1] == 'Migration'
      @is_migration = true
    end

    puts @is_migration
  end
end

file_path = ARGV[0]
file = File.open(File.expand_path(file_path))
code = file.read
file.close

source = RuboCop::AST::ProcessedSource.new(code, 3.0)
migration_parser = MigrationParser.new
source.ast.each_node { |node| migration_parser.process node }

