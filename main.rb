require 'yaml'
require 'rubocop-ast'
require_relative 'parser'
require 'fast_ignore'
require_relative 'logger'
class Train
  include Logger
  attr_reader :nodes, :gitignore, :models

  def initialize(folder)
    @nodes = []
    @models = []
    @dir = Dir.new(File.expand_path(folder))
    Dir.chdir @dir
    @folder = @dir

    analyse
  end

  def get_models; end

  def get_gemfile; end

  def get_controllers; end

  def get_migrations
    db_folder = @nodes[:children].find { |node| node[:path].include? 'db' }
    migrations =
      db_folder[:children].find { |node| node[:path].include? 'db/migrate' }
    migration_files = migrations[:children]

    migration_files.each do |node|
      file = File.open(node[:path])
      code = file.read
      file.close

      source = RuboCop::AST::ProcessedSource.new(code, RUBY_VERSION.to_f)
      migration_parser = MigrationParser.new

      # ast = source.ast
      source.ast.each_node { |node| migration_parser.process node }

      @models << migration_parser.model
    end
  end

  def analyse
    raise "No such file or directory #{@folder}" unless Dir.exist? @folder

    @nodes = get_node('', @folder)
  end

  def get_node(prefix, node)
    path = File.join(prefix, node)
    obj = {}

    # puts "DEBUG: #{path} #{ FastIgnore.new.allowed? path }"
    if path != @dir.to_path and
         FastIgnore.new.allowed?(path, directory: false) == false
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
# pp trains.nodes
trains.get_migrations
puts trains.models.to_yaml
