require 'rubocop-ast'
require 'parser'

class BaseParser < Parser::AST::Processor
  include RuboCop::AST::Traversal

  def result
    raise NotImplementedError
  end
end
