module Trains
  module DTO
    Migration = Data.define(:table_name, :modifier, :fields, :version)
  end
end
