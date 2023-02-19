require 'yaml'
require 'rubocop-ast'
require 'fast_ignore'
require 'zeitwerk'
require 'active_support/core_ext/string/inflections'
require 'parallel'

loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect('dto' => 'DTO')
loader.setup

module Trains
end
