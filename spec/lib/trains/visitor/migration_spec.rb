describe Trains::Visitor::Migration do
  let(:valid_migration) { File.expand_path "#{__FILE__}/../../../../fixtures/groups_migration.rb" }

  context 'Given a valid DB migration file path' do
    it 'returns an object with its metadata' do
      parser = described_class.new
      file_ast =
        RuboCop::AST::ProcessedSource.from_file(
          valid_migration,
          RUBY_VERSION.to_f
        ).ast
      file_ast.each_node { |node| parser.process(node) }

      expect(parser.result).to have_attributes(
        name: 'Group',
        fields:
          [
            Trains::DTO::Field.new(:title, :string),
            Trains::DTO::Field.new(:created_at, :datetime),
            Trains::DTO::Field.new(:updated_at, :datetime)
          ],
        version: 7.0
      )
    end
  end
end
