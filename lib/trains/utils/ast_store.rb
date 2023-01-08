require 'singleton'

module Trains
  module Utils
    class ASTStore
      include Singleton

      def initialize
        @store = {}
      end

      def set(file_path, ast_object)
        @store[file_path] = ast_object
      end

      def get(file_path)
        unless @store.key? file_path
          set(file_path,
              RuboCop::AST::ProcessedSource.from_file(file_path, RUBY_VERSION.to_f))
        end
        @store[file_path]
      end
    end
  end
end
