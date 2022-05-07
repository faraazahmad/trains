require 'colored'
require_relative 'lib/trains'

# Create parent tree
trains = Trains.new(ARGV[0])
pp trains
