module Trains
  module DTO
    class Model
      attr_reader :name, :fields, :version

      def initialize(name = nil, fields = [], version)
        @name = name
        @fields = fields
        @version = version
      end
    end
  end
end
