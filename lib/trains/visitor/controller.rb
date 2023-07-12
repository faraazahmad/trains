# frozen_string_literal: true

require_relative '../dto/callback'
require_relative '../dto/controller'
require_relative '../dto/method'

module Trains
  module Visitor
    # Visitor that parses controllers and returns a DTO::Controller object
    class Controller < Base
      include Utils::Args

      TRACKED_CALLBACKS = [
        :http_basic_authenticate_with
      ].freeze

      def initialize
        @method_list = []
        @methods = {}
        @class_name = nil
        @callbacks = []
      end

      def on_class(node)
        class_name = node.identifier.const_name.to_s
        parent_class = node.parent_class.const_name.to_s
        return unless controller?(parent_class)

        @class_name = class_name
        find_callbacks(node)
        parse_body(node) unless node.body.nil?
      end

      def result
        DTO::Controller.new(name: @class_name, method_list: @method_list, callbacks: @callbacks)
      end

      private

      def find_callbacks(klass_node)
        klass_node.each_descendant(:send) do |node|
          if node.receiver.nil? && TRACKED_CALLBACKS.include?(node.method_name)
            @callbacks << DTO::Callback.new(method: node.method_name,
                                            arguments: node.arguments.map { |arg| parse_args(arg) })
          end
        end
      end

      def parse_body(body)
        body.each_descendant(:def) do |child|
          @method_list << parse_method(child)
        end
      end

      def controller?(parent_class)
        parent_class.include? 'Controller'
      end

      def parse_method(node)
        DTO::Method.new(node.method_name.to_s)
      end
    end
  end
end
