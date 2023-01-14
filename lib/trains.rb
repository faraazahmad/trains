require "yaml"
require "rubocop-ast"
require "fast_ignore"
require "zeitwerk"
require "syntax_tree"

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect("dto" => "DTO")
loader.setup

module Trains
end
