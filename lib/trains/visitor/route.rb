require_relative "../dto/route"

module Trains
  module Visitor
    class Route < Base
      def_node_matcher :route_parent?, <<~PATTERN
        (block (send (send (send
          (const nil? :Rails) :application) :routes) :draw)
        ...)
      PATTERN

      def_node_matcher :route_method?, <<~PATTERN
        (send nil? %1 ...)
      PATTERN

      ALLOWED_VERBS = %i[get put post update delete resources scope]

      def initialize
        @route_list = []
      end

      def result
        @route_list
      end

      def on_block(node)
        return unless route_parent?(node)
        return if node.body.nil?

        node.body.each_child_node do |child|
          ALLOWED_VERBS.each do |verb|
            if route_method?(child, verb)
              @route_list << parse_route(child, verb)
            end
          end
        end
      end

      private

      def parse_route(node, verb)
        method = verb
        param =
          case node.arguments[0].type
          when :sym, :str
            node.arguments[0].value
          end
        options = parse_hash(node.arguments[1])
        DTO::Route.new(method: method, param: param, options: options)
      end

      def parse_hash(node)
        options = {}
        return options unless node.type == :hash

        node.each_pair { |key, value| options[key.value] = parse_value(value) }
      rescue StandardError => e
        puts node.parent
      ensure
        return options
      end

      def parse_value(node)
        case node.type
        when :hash
          parse_hash(node)
        when :array
          node.values.map { |value| parse_value(value) }
        when :send
          if node.method_name == :redirect
            { redirect: node.arguments.first.value }
          end
        else
          node.value
        end
      end
    end
  end
end
