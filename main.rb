require_relative 'lib/trains'

# Create parent tree
trains = Train.new(ARGV[0])
# trains.analyse
# puts trains.gitignore
# pp trains.nodes
pp trains.models
pp trains.controllers
