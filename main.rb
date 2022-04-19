require 'yaml'
require 'fast_ignore'

class Train
  attr_reader :nodes, :gitignore

  def initialize(folder)
    @nodes = []
    @gitignore = []
    @dir = Dir.new(File.expand_path(folder))
    Dir.chdir @dir
    @folder = @dir

    build_gitignore
    # puts @gitignore
    analyse
  end

  def get_models; end

  def get_gemfile; end

  def get_controllers; end

  def build_gitignore
    return unless @folder.children.include? '.gitignore'

    absolute_path = File.join(@folder, '.gitignore')
    @gitignore = File.readlines(absolute_path).map(&:chomp).filter { |line| line != '' && line[0] != '#' }
  end

  def analyse
    raise "No such file or directory #{@folder}" unless Dir.exist? @folder

    @nodes = get_node('', @folder)
  end

  def get_node(prefix, node)
    path = File.join(prefix, node)
    obj = {}

    # puts "DEBUG: #{path} #{ FastIgnore.new.allowed? path }"
    if path != @dir.to_path and FastIgnore.new.allowed?(path, directory: false) == false
      return nil
    end

    obj[:path] = path

    if Dir.exist? path
      children = []
      Dir.each_child path do |child|
        child_node = get_node(path, child)
        children.append(child_node) unless child_node.nil?
      end
      obj[:children] = children
    end

    obj
  end
end

# Create parent tree
trains = Train.new(ARGV[0])
# trains.analyse
# puts trains.gitignore
pp trains.nodes
