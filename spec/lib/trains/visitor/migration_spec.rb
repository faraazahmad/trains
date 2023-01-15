describe Trains::Visitor::Migration do
  let(:valid_migration) { 'spec/fixtures/groups_migration.rb' }

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
        name: 'CreateGroups',
        fields:
          Set[
            Trains::DTO::Field.new(:datetime, :created_at),
            Trains::DTO::Field.new(:datetime, :updated_at),
            Trains::DTO::Field.new(:string, :title)
          ],
        version: 7.0
      )
      # expect(parser.result).to eq(
      #   Trains::DTO::Model.new("CreateGroups", Set.new, 7.0)
      # )
    end
  end
end
