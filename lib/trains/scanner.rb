module Trains
  # Scanner parses all the code and stores metadata about the repo
  class Scanner
    include Utils

    def initialize(folder, options = {})
      @root_folder = folder
      @nodes = []
      @models = []
      @controllers = []
      @helpers = []
      @dir = File.expand_path(folder)
      @options = options

      # Dir.chdir @dir
    end

    def scan
      # Check if @folder is a Rails directory before beginning analysis
      rails_dir_result = RailsDir.check @dir
      case rails_dir_result
      in Result[data: true, error: nil]
        # Do nothing
      else
        return(
          Result.new(
            data: nil,
            error: ArgumentError.new("Not a Rails directory")
          )
        )
      end

      @migrations = Set[*get_migrations] unless @options[:migrations] == false
      @controllers = Set[*get_controllers] unless @options[:controllers] ==
        false
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

    def get_models
    end

    def get_helpers
      app_folder = @nodes[:children].find { |node| node[:path].include? "app" }
      helpers_folder =
        app_folder[:children].find { |node| node[:path].include? "app/helpers" }
      helpers =
        helpers_folder[:children].filter do |node|
          node[:path].end_with? "_helper.rb"
        end

      @helpers = parse_util(helpers, Visitor::Helper)
    end

    def get_gemfile
    end

    def get_controllers
      controllers =
        Dir.glob(File.join(@dir, "app", "controllers", "**", "*_controller.rb"))

      # puts controllers
      parse_util(controllers, Visitor::Controller)
    end

    def get_migrations
      migrations = Dir.glob(File.join(@dir, "db", "migrate", "**", "*.rb"))

      parse_util(migrations, Visitor::Migration)
    end

    def parse_util(file_nodes, visitor_class)
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
          visitor = visitor_class.new
          visitor.process(processed_source.ast)
          visitor.result
        end
      rescue StandardError => e
        puts e.backtrace
        Result.new(data: nil, error: e)
      end
    end

    def get_tree(node, prefix = "")
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
