require 'json'

class Train
  attr_reader :nodes

  def initialize(folder)
    @nodes = []
    @gitignore = []
    @folder = folder
  end

  def get_models; end

  def get_gemfile; end

  def get_controllers; end

  def build_gitignore
    return unless Dir.children.include? '.gitignore'

    absolute_path = File.expand(File.join(@folder, '.gitignore'))
    @gitignore = File.readlines(absolute_path).map(&:chomp).filter { |line| line != '' && line[0] != '#' }
  end

  def analyse
    raise "No such file or directory #{@folder}" unless Dir.exist? @folder

    @nodes = get_node('', @folder)
    @nodes
  end

  def get_node(prefix, node)
    path = File.join(prefix, node)
    obj = {}
    obj[:path] = path

    if Dir.exist? path
      children = []
      Dir.each_child path do |child|
        children.append(get_node(path, child))
      end
      obj[:children] = children
    end

    obj
  end
end

# Create parent tree
trains = Train.new(ARGV[0])
nodes = trains.analyse
puts nodes.nodes.to_json

# puts nodes
