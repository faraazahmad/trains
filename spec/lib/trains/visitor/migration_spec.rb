describe Trains::Visitor::Migration do
  let(:valid_migration) do
    File.expand_path "#{__FILE__}/../../../../fixtures/groups_migration.rb"
  end

  let (:group_users) do
    File.expand_path "#{__FILE__}/../../../../fixtures/groups_users_migration.rb"
  end

  let (:add_pending_migration) do
    File.expand_path "#{__FILE__}/../../../../fixtures/add_pending_migration.rb"
  end

  context "Given a valid DB migration file path" do
    it "returns an object with its metadata" do
      parser = described_class.new
      file_ast =
        RuboCop::AST::ProcessedSource.from_file(
          valid_migration,
          RUBY_VERSION.to_f
        ).ast
      file_ast.each_node { |node| parser.process(node) }

      expect(parser.result).to have_attributes(
        name: "Group",
        fields: [
          Trains::DTO::Field.new(:title, :string),
          Trains::DTO::Field.new(:created_at, :datetime),
          Trains::DTO::Field.new(:updated_at, :datetime)
        ],
        version: 7.0
      )
    end
  end

  context "Given a migration with null:false timestamp" do
    it "returns the right migration object" do
      parser = described_class.new
      file_ast =
        RuboCop::AST::ProcessedSource.from_file(
          group_users,
          RUBY_VERSION.to_f
        ).ast
      file_ast.each_node { |node| parser.process(node) }

      expect(parser.result).to have_attributes(
        name: "GroupUser",
        fields: [
          Trains::DTO::Field.new(:group_id, :integer),
          Trains::DTO::Field.new(:user_id, :integer),
          Trains::DTO::Field.new(:created_at, :datetime),
          Trains::DTO::Field.new(:updated_at, :datetime)
        ],
        version: 4.2
      )
    end
  end

  context "Given a valid DB migration with add column on a single line" do
    it "returns an object with its metadata" do
      parser = described_class.new
      file_ast =
        RuboCop::AST::ProcessedSource.from_file(
          add_pending_migration,
          RUBY_VERSION.to_f
        ).ast
      file_ast.each_node { |node| parser.process(node) }

      expect(parser.result).to have_attributes(
        name: "Group",
        fields: [
          Trains::DTO::Field.new(:title, :string),
          Trains::DTO::Field.new(:created_at, :datetime),
          Trains::DTO::Field.new(:updated_at, :datetime)
        ],
        version: 7.0
      )
    end
  end
end
