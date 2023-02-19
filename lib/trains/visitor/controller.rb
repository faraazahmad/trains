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
        class_name = node.identifier.const_name
        parent_class = node.parent_class.const_name.to_sym

        is_controller =
          if parent_class.nil?
            true if class_name == :ApplicationController
          else
            parent_class == :"ActionController::Base"
          end
        return unless is_controller

        @class_name = class_name
      end

      # List out all controller methods
      def on_def(node)
        method_name = node.method_name
        @method_list.append(
          DTO::Method.new(name: method_name.to_s, visibility: nil, source: nil)
        )
      end

      def result
        DTO::Controller.new(name: @class_name, method_list: @method_list.uniq)
      end
    end
  end
end
