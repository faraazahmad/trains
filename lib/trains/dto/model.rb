module Trains
  module DTO
    Model = Data.define(
      :name, :fields, :version, :renamed_columns, :removed_columns, :ignored_columns
    ) do
      def initialize(name:, fields:, version:, renamed_columns: [],
                     removed_columns: [], ignored_columns: [])
        super(name:, fields:, version:, renamed_columns:, removed_columns:, ignored_columns:)
      end
    end
  end
end
