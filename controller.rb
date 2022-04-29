require 'rubocop-ast'
require 'parser'
require 'set'
require_relative 'logger'

class ControllerParser < Parser::AST::Processor
  include RuboCop::AST::Traversal
  include Logger

  attr_reader :scope, :is_controller, :methods

  def initialize
    @methods = Set.new
    @is_class = false
    @is_controller = false
    @class_name = nil

    @scope = { class: nil, method: nil, send: nil }
  end

  def on_class(node)
    # debug node
    @is_class = true
    @scope[:class] = node.identifier.const_name

    # debug @scope
    parent_class = node.parent_class.const_name

    # debug const_ref

    # inherited_class = const_ref.const_name
    # @is_migration = true if inherited_class == 'ActiveRecord::Migration'
    @is_controller = true if parent_class == 'ApplicationController'
  end

  def on_def(node)
    method_name = node.method_name
    @methods.add method_name
    # parse_migration_method node
  end
end

file_path = ARGV[0]
file = File.open(File.expand_path(file_path))
code = file.read
file.close

source = RuboCop::AST::ProcessedSource.new(code, RUBY_VERSION.to_f)
parser = ControllerParser.new
# ast = source.ast
source.ast.each_node { |node| parser.process node }
puts parser.methods.to_a
