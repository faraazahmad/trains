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

      @models = Set[*get_models] unless @options[:models] == false
      @migrations = Set[*get_migrations] unless @options[:migrations] == false
      @controllers = Set[*get_controllers] unless @options[:controllers] ==
        false
      @routes = Set[*get_routes] unless @options[:routes] == false
      # @helpers = get_helpers

      # Create instance of Trains::DTO::App
      DTO::App.new(
        name: nil,
        controllers: @controllers,
        models: @models,
        migrations: @migrations,
        helpers: @helpers,
        routes: @routes
      )
    end

    private

    def get_routes
      route_file = [File.join(@dir, "config", "routes.rb")]

      routes_results = parse_util(route_file, Visitor::Route)
      routes_results
        .select { |result| result.error.nil? }
        .map { |result| result.data }
    end

    def get_models
      schema_file = [File.join(@dir, "db", "schema.rb")]
      return [] unless File.exist?(schema_file.first)

      models_results = parse_util(schema_file, Visitor::Schema)
      models_results
        .select { |result| result.error.nil? }
        .map { |result| result.data }
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

      controller_results = parse_util(controllers, Visitor::Controller)
      controller_results
        .select { |result| result.error.nil? }
        .map { |result| result.data }
    end

    def get_migrations
      migrations = Dir.glob(File.join(@dir, "db", "migrate", "**", "*.rb"))

      migration_results = parse_util(migrations, Visitor::Migration)
      migration_results
        .select { |result| result.error.nil? }
        .map { |result| result.data }
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

      Parallel.map(file_nodes) do |node|
        begin
          processed_source =
            RuboCop::AST::ProcessedSource.from_file(node, RUBY_VERSION.to_f)
          visitor = visitor_class.new
          visitor.process(processed_source.ast)

          Result.new(data: visitor.result, error: nil)
        rescue StandardError => e
          puts "An error occurred while parsing #{node}. Use debug option to view backtrace. Skipping file..."
          puts e.backtrace if @options[:debug]

          Result.new(data: nil, error: e)
        end
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
