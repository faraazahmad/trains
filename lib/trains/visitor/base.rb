require "rubocop-ast"
require "parser"

module Trains
  module Visitor
    class Base < Parser::AST::Processor
      include RuboCop::AST::Traversal
      extend RuboCop::AST::NodePattern::Macros

      def result
        raise NotImplementedError
      end
    end
  end
end
