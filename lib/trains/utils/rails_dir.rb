module Trains
  module Utils
    class RailsDir
      # checks if supplied dir is in a Rails app dir
      def self.check(root_path)
        rails_bin = File.join(root_path, "bin", "rails")

        Result.new(data: File.exist?(rails_bin), error: nil)
      end
    end
  end
end
