module Trains
  module DTO
    class Model
      attr_accessor :name, :fields

      def initialize(name = nil, fields = [])
        @name = name
        @fields = fields
      end
    end
  end
end
