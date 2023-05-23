describe Trains::Visitor::Migration do
  let(:valid_migration) do
    File.expand_path "#{__FILE__}/../../../../fixtures/groups_migration.rb"
  end

  let(:group_users) do
    File.expand_path "#{__FILE__}/../../../../fixtures/groups_users_migration.rb"
  end

  let(:add_pending_migration) do
    File.expand_path "#{__FILE__}/../../../../fixtures/add_pending_migration.rb"
  end

  let(:remove_column_migration) do
    File.expand_path "#{__FILE__}/../../../../fixtures/remove_column_migration.rb"
  end

  let(:create_people_migration) do
    File.expand_path "#{__FILE__}/../../../../fixtures/create_people.rb"
  end

  context 'Given a valid DB migration file path' do
    it 'returns an object with its metadata' do
      parser = described_class.new
      file_ast =
        RuboCop::AST::ProcessedSource.from_file(
          valid_migration,
          RUBY_VERSION.to_f
        ).ast
      file_ast.each_node { |node| parser.process(node) }

      expect(parser.result).to eq(
        Trains::DTO::Migration.new(
          table_name: 'Group',
          modifier: :create_table,
          fields: [
            Trains::DTO::Field.new(:title, :string),
            Trains::DTO::Field.new(:created_at, :datetime),
            Trains::DTO::Field.new(:updated_at, :datetime)
          ],
          version: 7.0
        )
      )
    end

    it 'sdsd' do
      parser = described_class.new
      file_ast =
        RuboCop::AST::ProcessedSource.from_file(
          create_people_migration,
          RUBY_VERSION.to_f
        ).ast
      file_ast.each_node { |node| parser.process(node) }

      expect(parser.result).to eq(
        Trains::DTO::Migration.new(
          table_name: 'Person',
          modifier: :create_table,
          fields: [
            Trains::DTO::Field.new(:name, :string),
            Trains::DTO::Field.new(:age, :integer),
            Trains::DTO::Field.new(:job, :string),
            Trains::DTO::Field.new(:bio, :text),
            Trains::DTO::Field.new(:created_at, :datetime),
            Trains::DTO::Field.new(:updated_at, :datetime)
          ],
          version: 7.0
        )
      )
    end
  end

  context 'Given a migration with null:false timestamp' do
    it 'returns the right migration object' do
      parser = described_class.new
      file_ast =
        RuboCop::AST::ProcessedSource.from_file(
          group_users,
          RUBY_VERSION.to_f
        ).ast
      file_ast.each_node { |node| parser.process(node) }

      expect(parser.result).to eq(
        Trains::DTO::Migration.new(
          table_name: 'GroupUser',
          modifier: :create_table,
          fields: [
            Trains::DTO::Field.new(:group_id, :integer),
            Trains::DTO::Field.new(:user_id, :integer),
            Trains::DTO::Field.new(:created_at, :datetime),
            Trains::DTO::Field.new(:updated_at, :datetime)
          ],
          version: 4.2
        )
      )
    end
  end

  context 'Given a migration with remove_column' do
    it 'returns a migration with remove_column' do
      parser = described_class.new
      file_ast =
        RuboCop::AST::ProcessedSource.from_file(
          remove_column_migration,
          RUBY_VERSION.to_f
        ).ast
      file_ast.each_node { |node| parser.process(node) }

      expect(parser.result).to eq(
        Trains::DTO::Migration.new(
          table_name: 'Post',
          modifier: :remove_column,
          fields: [Trains::DTO::Field.new(:reply_below_post_number, nil)],
          version: 4.2
        )
      )
    end
  end

  context 'Given a valid DB migration with add column on a single line' do
    it 'returns an object with its metadata' do
      parser = described_class.new
      file_ast =
        RuboCop::AST::ProcessedSource.from_file(
          add_pending_migration,
          RUBY_VERSION.to_f
        ).ast
      file_ast.each_node { |node| parser.process(node) }

      expect(parser.result).to eq(
        Trains::DTO::Migration.new(
          table_name: 'UserStat',
          modifier: :add_column,
          fields: [Trains::DTO::Field.new(:pending_posts_count, :integer)],
          version: 6.1
        )
      )
    end
  end
end
