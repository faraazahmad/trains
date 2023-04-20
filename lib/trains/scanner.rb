module Trains
  # Scanner parses all the code and stores metadata about the repo
  class Scanner
    include Utils

    def initialize(folder, options = {})
      @root_folder = folder
      @models = {}
      @controllers = {}
      @helpers = {}
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
            error: ArgumentError.new('Not a Rails directory')
          )
        )
      end

      @models = generate_models unless @options[:models] == false
      @controllers = get_controllers unless @options[:controllers] == false
      @routes = get_routes.to_set unless @options[:routes] == false
      # TODO: @helpers = get_helpers

      # Create instance of Trains::DTO::App
      DTO::App.new(
        name: nil,
        controllers: @controllers,
        models: @models,
        helpers: @helpers,
        routes: @routes
      )
    end

    private

    # Generate models from either db/schema.rb
    # else stitch together migrations to create models
    def generate_models
      return get_models if File.exist?(File.join(@dir, 'db', 'schema.rb'))

      migrations = get_migrations
      Utils::MigrationTailor.stitch(migrations)
    end

    def get_routes
      route_file = [File.join(@dir, 'config', 'routes.rb')]

      routes_results = parse_util(route_file, Visitor::Route)
      routes_results
        .select { |result| result.error.nil? }
        .map(&:data)
        .flatten
    end

    def get_models
      result_hash = {}
      schema_file = [File.join(@dir, 'db', 'schema.rb')]
      models_results = parse_util(schema_file, Visitor::Schema)

      models_results
        .select { |result| result.error.nil? }
        .map(&:data)
        .flatten
        .each { |model| result_hash[model.name] = model }

      result_hash
    end

    def get_helpers; end

    def get_gemfile; end

    def get_controllers
      result_hash = {}
      controllers =
        Dir.glob(File.join(@dir, 'app', 'controllers', '**', '*_controller.rb'))
      controller_results = parse_util(controllers, Visitor::Controller)

      controller_results
        .select { |result| result.error.nil? }
        .map(&:data)
        .flatten
        .each { |controller| result_hash[controller.name] = controller }

      result_hash
    end

    def get_migrations
      migrations = Dir.glob(File.join(@dir, 'db', 'migrate', '**', '*.rb'))
      migration_results = parse_util(migrations, Visitor::Migration)

      migration_results
        .select { |result| result.error.nil? }
        .map(&:data)
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
        processed_source =
          RuboCop::AST::ProcessedSource.from_file(node, RUBY_VERSION.to_f)
        visitor = visitor_class.new
        visitor.process(processed_source.ast)

        Result.new(data: visitor.result, error: nil)
      rescue StandardError => e
        puts "An error occurred while parsing #{node}. Use debug option to view backtrace. Skipping file..."
        if @options[:debug]
          puts e.message
          puts e.backtrace
        end

        Result.new(data: nil, error: e)
      end
    end
  end
end
