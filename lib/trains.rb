require 'yaml'
require 'rubocop-ast'
require_relative 'parsers/migration'
require_relative 'parsers/helper'
require_relative 'parsers/controller'
require 'fast_ignore'
require_relative 'utils/logger'
require_relative 'utils/rails_dir'

class Trains
  include Logger
  include RailsDir
  attr_reader :models, :controllers

  def initialize(folder)
    @nodes = []
    @models = []
    @controllers = []
    @helpers = []
    @dir = Dir.new(File.expand_path(folder))
    Dir.chdir @dir
    @folder = @dir

    analyse
  end

  def get_models; end

  def get_helpers
    app_folder = @nodes[:children].find { |node| node[:path].include? 'app' }
    helpers_folder =
      app_folder[:children].find { |node| node[:path].include? 'app/helpers' }
    helpers =
      helpers_folder[:children].filter do |node|
        node[:path].end_with? '_helper.rb'
      end

    @helpers = parse_util(helpers, HelperParser)
  end

  def get_gemfile; end

  def parse_util(obj, klass)
    unless obj.class.include? Enumerable
      raise TypeError("Object of type #{type.class} is not iterable")
    end

    results = []
    threads = []
    parser = klass.new

    obj.each do |node|
      threads <<
        Thread.new do
          file = File.open(node[:path])
          code = file.read
          file.close

          source = RuboCop::AST::ProcessedSource.new(code, RUBY_VERSION.to_f)
          parser = klass.new

          source.ast.each_node { |ast_node| parser.process ast_node }
          Thread.current[:output] = parser.result
        end
    end

    threads.each { |thr| thr.join }
    results = threads.map { |t| t[:output] }

    results
  end

  def get_controllers
    # debug nodes[:children]
    app_folder = @nodes[:children].find { |node| node[:path].include? 'app' }
    controllers_folder =
      app_folder[:children].find do |node|
        node[:path].include? 'app/controllers'
      end
    controllers =
      controllers_folder[:children].filter do |node|
        node[:path].end_with? '_controller.rb'
      end

    @controllers = parse_util(controllers, ControllerParser)
  end

  def get_migrations
    db_folder = @nodes[:children].find { |node| node[:path].include? 'db' }
    migrations_folder =
      db_folder[:children].find { |node| node[:path].include? 'db/migrate' }
    migrations = migrations_folder[:children]

    @models = parse_util(migrations, MigrationParser)
  end

  def analyse
    @nodes = get_node('', @folder)

    # Check if @folder is a Rails directory before beginning analysis
    check @nodes
    get_migrations
    get_controllers
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
