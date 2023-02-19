module Trains
  # Scanner parses all the code and stores metadata about the repo
  class Scanner
    include Utils

    attr_accessor :models, :controllers, :helpers, :migrations

    def initialize(folder)
      @root_folder = folder
      @nodes = []
      @models = []
      @controllers = []
      @helpers = []
      @dir = Dir.new(File.expand_path(folder))
      Dir.chdir @dir
    end

    def scan
      # @nodes = get_tree(@dir)

      # Check if @folder is a Rails directory before beginning analysis
      rails_dir_result = RailsDir.check @dir
      case rails_dir_result
      in Result[data: true, error: nil]
        # Do nothing
      else
        return(
          Result.new(
            data: nil,
            error: ArgumentError.new('Not a Rails directory')
          )
        )
      end

      @migrations = Set[*get_migrations]
      @controllers = Set[*get_controllers]
      # @helpers = get_helpers
      # @models = get_models

      # Create instance of Trains::DTO::App
      DTO::App.new(
        name: nil,
        controllers: @controllers,
        models: @models,
        migrations: @migrations,
        helpers: @helpers
      )
    end

    # Build central ASTStore
    def build_ast_store
      all_files = Dir.glob(File.join(@root_folder, '**', '*.rb'))
      Parallel.each(all_files) do |file_path|
        ASTStore.instance.set(
          file_path,
          RuboCop::AST::ProcessedSource.from_file(file_path, RUBY_VERSION.to_f)
        )
      end
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

      @helpers = parse_util(helpers, Visitor::Helper)
    end

    def get_gemfile; end

    def get_controllers
      controllers =
        Dir.glob(File.join(@dir, 'app', 'controllers', '**', '*_controller.rb'))

      parse_util(controllers, Visitor::Controller)
    end

    def get_migrations
      migrations = Dir.glob(File.join(@dir, 'db', 'migrate', '**', '*.rb'))

      parse_util(migrations, Visitor::Migration)
    end

    def parse_util(file_nodes, klass)
      unless file_nodes.class.include? Enumerable
        return(
          Result.new(
            data: nil,
            error:
              TypeError.new(
                "Object of type #{file_nodes.class} is not iterable"
              )
          )
        )
      end

      begin
        Parallel.map(file_nodes) do |node|
          processed_source =
            RuboCop::AST::ProcessedSource.from_file(node, RUBY_VERSION.to_f)
          visitor = klass.new
          visitor.process(processed_source.ast)
          visitor.result
        end
      rescue StandardError => e
        puts e.backtrace
        Result.new(data: nil, error: e)
      end
    end

    def get_tree(node, prefix = '')
      path = File.join(prefix, node)
      obj = { path: nil }

      # puts "DEBUG: #{path} #{ FastIgnore.new.allowed? path }"
      if path != @dir.to_path &&
         FastIgnore.new.allowed?(path, directory: false) == false
        return nil
      end

      if Dir.exist? path
        children = []
        Dir.each_child path do |child|
          child_node = get_tree(child, path)
          children.append(child_node) unless child_node.nil?
        end
        obj[:children] = children
      end

      obj
    end
  end
end
