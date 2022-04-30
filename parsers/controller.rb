require_relative 'base_parser'
require_relative '../utils/controller'
require 'yaml'

class ControllerParser < BaseParser
  attr_reader :controller, :is_controller, :methods

  def initialize
    @controller = Controller.new
    @is_class = false
    @is_controller = false
    @class_name = nil

    @scope = { class: nil, method: nil, send: nil }
  end

  def on_class(node)
    @is_class = true

    parent_class = node.parent_class.const_name
    @is_controller = true if parent_class.to_sym == :ApplicationController
    return unless @is_controller

    @controller.name = node.identifier.const_name
  end

  # List out all controller methods
  def on_def(node)
    method_name = node.method_name
    @controller.controller_methods.add method_name
  end
end

# file_path = ARGV[0]
# file = File.open(File.expand_path(file_path))
# code = file.read
# file.close

# source = RuboCop::AST::ProcessedSource.new(code, RUBY_VERSION.to_f)
# parser = ControllerParser.new
# # ast = source.ast
# source.ast.each_node { |node| parser.process node }
# puts parser.controller.to_yaml
