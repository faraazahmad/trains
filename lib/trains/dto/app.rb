# frozen_string_literal: true

module Trains
  module DTO
    App =
      Data.define(:name, :controllers, :models, :helpers, :routes)
  end
end
