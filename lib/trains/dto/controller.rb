require 'set'

module Trains
  module DTO
    Controller = Struct.new('Controller', :name, :method_list, keyword_init: true)
  end
end
