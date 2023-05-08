require_relative '../dto/route'

module Trains
  module Visitor
    # Visitor for Parsing Rails routes
    class Route < Base
      include Utils::Args

      def_node_matcher :route_parent?, <<~PATTERN
        (block (send (send (send
          (const nil? :Rails) :application) :routes) :draw)
        ...)
      PATTERN

      def_node_matcher :route_method?, <<~PATTERN
        (send nil? %1 ...)
      PATTERN

      ALLOWED_VERBS = %i[get put post update delete resources scope].freeze

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
        DTO::Route.new(method:, param:, options:)
      end
    end
  end
end
