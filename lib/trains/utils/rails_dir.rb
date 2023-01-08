module Trains
  module Utils
    class RailsDir
      # checks if supplied dir is in a Rails app dir
      def self.check(nodes)
        bin_folder = nodes[:children].find { |node| node[:path].include? 'bin' }
        return Result.new(false, ArgumentError.new('Provided folder is not a Rails project')) if bin_folder.nil?

        rails_bin = bin_folder[:children].find { |node| node[:path].include? 'rails' }
        return Result.new(true, nil) unless rails_bin.nil?

        Result.new(false, nil)
      end
    end
  end
end
