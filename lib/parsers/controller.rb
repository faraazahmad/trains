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

    parent_class = node.parent_class.const_name.to_sym
    @controller.name = node.identifier.const_name.to_sym
    if parent_class.nil?
      @is_controller = true if @controller.name == :ApplicationController
    else
      @is_controller = true if parent_class == :ApplicationController
    end

    return unless @is_controller
  end

  # List out all controller methods
  def on_def(node)
    method_name = node.method_name
    @controller.controller_methods.add method_name
  end

  def result
    @controller
  end
end
