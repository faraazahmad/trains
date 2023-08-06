describe Trains::Visitor::Model do
  context 'Given an ApplicationRecord model' do
    it 'generates migrations for association method calls' do
      model = <<~RUBY
        class AccountPin < ApplicationRecord
          self.ignored_columns = [:foo, bar, :baz, 'what']
        end
      RUBY

      parser = described_class.new
      model_ast =
        RuboCop::AST::ProcessedSource.new(model, RUBY_VERSION.to_f)
      model_ast.ast.each_node { |node| parser.process(node) }

      expect(parser.result).to eq(
        [
        Trains::DTO::Migration.new(
          table_name: 'AccountPin',
          modifier: :ignore_column,
          fields: [Trains::DTO::Field.new(:foo, nil), Trains::DTO::Field.new(:baz, nil)],
          version: nil
        )
        ]
      )
    end
  end
end
