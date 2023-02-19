module Trains
  module DTO
    App = Struct.new(
      'App',
      :name,
      :controllers,
      :models,
      :migrations,
      :helpers,
      keyword_init: true
    )
  end
end
