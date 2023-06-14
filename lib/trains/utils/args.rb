# frozen_string_literal: true

module Trains
  module Utils
    # utility module to deal with parsing of arguments
    module Args
      def parse_args(node)
        return if node.nil?

        case node.type
        when :hash
          parse_hash(node)
        else
          parse_value(node)
        end
      end

      def parse_hash(node)
        options = {}
        return options unless node.type == :hash

        node.each_pair { |key, value| options[key.value] = parse_value(value) }
      rescue StandardError => e
        puts "Error boi"
        puts e
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
        when :true
          true
        when :false
          false
        when :symbol, :string
          node.value
        end
      end
    end
  end
end
