require 'rubocop-ast'
require 'parser'
require_relative '../logger'

class BaseParser < Parser::AST::Processor
  include RuboCop::AST::Traversal
  include Logger
end
