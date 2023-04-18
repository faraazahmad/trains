module Trains
  module Visitor
    # Visitor that parses DB migration and associates them with Rails models
    class Schema < Base
      def_node_matcher :versioned_schema?, <<~PATTERN
        (block
          (send (send (const (const nil? :ActiveRecord) :Schema) :[] (float ...)) :define ...)
        ...)
      PATTERN

      def_node_matcher :unversioned_schema?, <<~PATTERN
       (block
        (send (const (const nil? :ActiveRecord) :Schema) :define ...)
       ...)
      PATTERN

      def initialize
        @models = []
        @columns = []
        @is_versioned = false
      end

      def on_block(node)
        is_schema = versioned_schema?(node) || unversioned_schema?(node)
        return unless is_schema

        process_schema_body(node)
      end

      def result
        @models
      end

      private

      def each_table(ast)
        case ast.body.type
        when :begin
          ast.body.children.each do |node|
            next unless node.block_type? && node.method?(:create_table)

            yield(node)
          end
        else
          yield ast.body
        end
      end

      def each_content(node, &block)
        return enum_for(__method__, node) unless block

        case node.body&.type
        when :begin
          node.body.children.each(&block)
        else
          yield(node.body)
        end
      end

      def build_columns(node)
        each_content(node)
          .map do |child|
            next unless child&.send_type?
            next if child.method?(:index)

            DTO::Field.new(
              name: child.first_argument.str_content,
              type: child.method_name
            )
          end
          .compact
      end

      def process_schema_body(node)
        each_table(node) do |table|
          @table_name = table.send_node.first_argument.value
          @columns = build_columns(table)

          @models << DTO::Model.new(
            name: @table_name.singularize.camelize,
            fields: @columns,
            version: nil
          )
        end
      end
    end
  end
end
