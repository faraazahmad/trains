module Trains
  module Utils
    module Logger
      def self.debug(log)
        puts '[DEBUG]:'
        pp log
      end
    end
  end
end
