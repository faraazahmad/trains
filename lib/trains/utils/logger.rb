# frozen_string_literal: true

module Trains
  module Utils
    # Module with logging basics
    module Logger
      def self.debug(log)
        puts '[DEBUG]:'
        # skipcq: RB-RB-LI1008
        pp log
      end
    end
  end
end
