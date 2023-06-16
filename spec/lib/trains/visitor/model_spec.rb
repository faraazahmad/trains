describe Trains::Visitor::Model do
  context 'Given an ApplicationRecord model' do
    it 'generates migrations for association method calls' do
      model = <<~RUBY
        class AccountPin < ApplicationRecord
          has_and_belongs_to_many :accounts
        end
      RUBY

      parser = described_class.new
      model_ast =
        RuboCop::AST::ProcessedSource.new(model, RUBY_VERSION.to_f)
      model_ast.ast.each_node { |node| parser.process(node) }
    end
  end
end
