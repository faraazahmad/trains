require_relative '../dto/controller'
require_relative '../dto/method'

module Trains
  module Visitor
    # Visitor that parses controllers and returns a DTO::Controller object
    class Controller < Base
      def initialize
        @method_list = []
        @methods = {}
        @class_name = nil
      end

      def on_class(node)
        class_name = node.identifier.const_name.to_s
        parent_class = node.parent_class.const_name.to_s
        return unless controller?(parent_class)

        @class_name = class_name
        parse_body(node.body) unless node.body.nil?
      end

      def result
        DTO::Controller.new(name: @class_name, method_list: @method_list.uniq)
      end

      private

      def parse_body(body)
        body.each_child_node do |child|
          @method_list << parse_method(child) if child.type == :def
        end
      end

      def controller?(parent_class)
        %w[ActionController::Base ApplicationController].include? parent_class
      end

      def parse_method(node)
        DTO::Method.new(name: node.method_name.to_s)
      end
    end
  end
end
