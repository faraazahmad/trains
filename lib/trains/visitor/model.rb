# frozen_string_literal: true

module Trains
  module Visitor
    # Visit ActiveRecord models and add migrations for reference fields
    class Model < Base
      POSSIBLE_ASSOCIATIONS = %i[
        has_many
        belongs_to
        has_one
        has_and_belongs_to_many
        ignored_columns=
      ].freeze
      MODEL_PARENT_CLASSES = %w[
        ApplicationRecord
        ActiveRecord::Base
      ].freeze
      attr_reader :result

      # skipcq: RB-LI1087
      def initialize
        @result = []
      end

      def on_class(node)
        return unless node.parent_class
        return unless MODEL_PARENT_CLASSES.include? node.parent_class.source

        @model_class = node.identifier.source
        node.each_descendant(:send) { |send_node| parse_model(send_node) }
      end

      def parse_model(node)
        return unless POSSIBLE_ASSOCIATIONS.include?(node.method_name)

        if node.method_name == :ignored_columns=
          return if node.arguments.nil?
          return unless node.arguments.first.is_a? RuboCop::AST::ArrayNode

          arguments = node.arguments.first.to_a
          arguments = arguments.select do |child|
            child.is_a?(RuboCop::AST::SymbolNode) || child.is_a?(RuboCop::AST::StrNode)
          end.map(&:value)

          @result << DTO::Migration.new(
            @model_class,
            :ignore_column,
            [*arguments.map { |arg| DTO::Field.new(arg.to_sym, nil) }],
            nil
          )

          return
        end

        @result << DTO::Migration.new(
          @model_class,
          :add_column,
          [DTO::Field.new(node.arguments.first.value.to_sym, :bigint)],
          nil
        )

        return unless node.method_name == :has_and_belongs_to_many

        @result <<
          DTO::Migration.new(
            node.arguments.first.value.to_s.singularize.camelize,
            :add_column,
            [DTO::Field.new(@model_class.tableize.to_sym, :bigint)],
            nil
          )
      end
    end
  end
end
