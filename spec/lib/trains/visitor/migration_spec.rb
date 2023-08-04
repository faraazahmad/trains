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

  let(:denormalize_migration) do
    File.expand_path "#{__FILE__}/../../../../fixtures/denormalize_migration.rb"
  end

  let(:create_join_migrations) do
    File.expand_path "#{__FILE__}/../../../../fixtures/create_join_table.rb"
  end

  let(:safety_assured) do
    File.expand_path "#{__FILE__}/../../../../fixtures/safety_assured.rb"
  end

  let(:change_table) do
    File.expand_path "#{__FILE__}/../../../../fixtures/change_table.rb"
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
        [
          Trains::DTO::Migration.new(
            table_name: 'Group',
            modifier: :create_table,
            fields: [
              Trains::DTO::Field.new(:id, :bigint),
              Trains::DTO::Field.new(:title, :string),
              Trains::DTO::Field.new(:created_at, :datetime),
              Trains::DTO::Field.new(:updated_at, :datetime)
            ],
            version: 7.0
          ),
          Trains::DTO::Migration.new(
            table_name: 'Group',
            modifier: :add_column,
            fields: [Trains::DTO::Field.new(:name, :string)],
            version: 7.0
          )
        ]
      )
    end

    it 'returns a valid migration' do
      parser = described_class.new
      file_ast =
        RuboCop::AST::ProcessedSource.from_file(
          create_people_migration,
          RUBY_VERSION.to_f
        ).ast
      file_ast.each_node { |node| parser.process(node) }

      expect(parser.result).to eq(
        [
          Trains::DTO::Migration.new(
            table_name: 'Person',
            modifier: :create_table,
            fields: [
              Trains::DTO::Field.new(:id, :bigint),
              Trains::DTO::Field.new(:name, :string),
              Trains::DTO::Field.new(:age, :integer),
              Trains::DTO::Field.new(:job, :string),
              Trains::DTO::Field.new(:bio, :text),
              Trains::DTO::Field.new(:created_at, :datetime),
              Trains::DTO::Field.new(:updated_at, :datetime)
            ],
            version: 7.0
          )
        ]
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
        [
          Trains::DTO::Migration.new(
            table_name: 'GroupUser',
            modifier: :create_table,
            fields: [
              Trains::DTO::Field.new(:id, :bigint),
              Trains::DTO::Field.new(:group_id, :integer),
              Trains::DTO::Field.new(:user_id, :integer),
              Trains::DTO::Field.new(:car_id, :bigint),
              Trains::DTO::Field.new(:person_id, :bigint),
              Trains::DTO::Field.new(:created_at, :datetime),
              Trains::DTO::Field.new(:updated_at, :datetime)
            ],
            version: 4.2
          )
        ]
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
        [
          Trains::DTO::Migration.new(
            table_name: 'Post',
            modifier: :remove_column,
            fields: [Trains::DTO::Field.new(:reply_below_post_number, nil)],
            version: 4.2
          )
        ]
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
        [
          Trains::DTO::Migration.new(
            table_name: 'UserStat',
            modifier: :add_column,
            fields: [Trains::DTO::Field.new(:pending_posts_count, :integer)],
            version: 6.1
          )
        ]
      )
    end

    context 'Given a DB migration within safety_assured' do
      it 'creates a table with their names combined' do
        parser = described_class.new
        file_ast =
          RuboCop::AST::ProcessedSource.from_file(
            safety_assured,
            RUBY_VERSION.to_f
          ).ast
        file_ast.each_node { |node| parser.process(node) }

        expect(parser.result).to eq(
          [
            Trains::DTO::Migration.new(
              table_name: 'WebPushSubscription',
              modifier: :add_reference,
              fields: [
                Trains::DTO::Field.new(:parent_id, :bigint)
              ],
              version: 5.1
            ),
            Trains::DTO::Migration.new(
              table_name: 'WebPushSubscription',
              modifier: :add_reference,
              fields: [
                Trains::DTO::Field.new(:car_id, :bigint)
              ],
              version: 5.1
            ),
            Trains::DTO::Migration.new(
              table_name: 'WebPushSubscription',
              modifier: :add_reference,
              fields: [
                Trains::DTO::Field.new(:juice_id, :bigint)
              ],
              version: 5.1
            ),
            Trains::DTO::Migration.new(
              table_name: 'EmailDomainBlock',
              modifier: :add_reference,
              fields: [
                Trains::DTO::Field.new(:parent_id, :bigint)
              ],
              version: 5.1
            ),
            Trains::DTO::Migration.new(
              table_name: 'User',
              modifier: :add_reference,
              fields: [
                Trains::DTO::Field.new(:role_id, :bigint)
              ],
              version: 5.1
            )
          ]
        )
      end
    end

    context 'Given a create_join_table migration' do
      it 'creates a table with their names combined' do
        parser = described_class.new
        file_ast =
          RuboCop::AST::ProcessedSource.from_file(
            create_join_migrations,
            RUBY_VERSION.to_f
          ).ast
        file_ast.each_node { |node| parser.process(node) }

        expect(parser.result).to eq(
          [
            Trains::DTO::Migration.new(
              table_name: 'StatusesTags',
              modifier: :create_join_table,
              fields: [
                Trains::DTO::Field.new(:status_id, :bigint),
                Trains::DTO::Field.new(:tag_id, :bigint),
                Trains::DTO::Field.new(:job, :string),
                Trains::DTO::Field.new(:bio, :text),
                Trains::DTO::Field.new(:created_at, :datetime),
                Trains::DTO::Field.new(:updated_at, :datetime)
              ],
              version: 7.0
            )
          ]
        )
      end
    end

    context 'Given a denormalized DB migration' do
      it 'returns an object with its metadata' do
        parser = described_class.new
        file_ast =
          RuboCop::AST::ProcessedSource.from_file(
            denormalize_migration,
            RUBY_VERSION.to_f
          ).ast
        file_ast.each_node { |node| parser.process(node) }

        expect(parser.result).to eq(
          [
            Trains::DTO::Migration.new(
              table_name: 'Post',
              modifier: :add_column,
              fields: [Trains::DTO::Field.new(:expression1_count, :integer)],
              version: 4.2
            ),
            Trains::DTO::Migration.new(
              table_name: 'Post',
              modifier: :add_column,
              fields: [Trains::DTO::Field.new(:expression2_count, :integer)],
              version: 4.2
            ),
            Trains::DTO::Migration.new(
              table_name: 'ForumThread',
              modifier: :add_column,
              fields: [Trains::DTO::Field.new(:expression1_count, :integer)],
              version: 4.2
            ),
            Trains::DTO::Migration.new(
              table_name: 'ForumThread',
              modifier: :add_column,
              fields: [Trains::DTO::Field.new(:expression2_count, :integer)],
              version: 4.2
            )
          ]
        )
      end
    end
  end

  context 'Give a migration containing change_table migration' do
    it 'create the appropriate migration objects' do
      parser = described_class.new
      file_ast =
        RuboCop::AST::ProcessedSource.from_file(
          change_table,
          RUBY_VERSION.to_f
        ).ast
      file_ast.each_node { |node| parser.process(node) }

      expect(parser.result).to eq(
        [
          Trains::DTO::Migration.new(
            table_name: 'Group',
            modifier: :create_table,
            fields: [
              Trains::DTO::Field.new(:id, :bigint),
              Trains::DTO::Field.new(:title, :string),
              Trains::DTO::Field.new(:created_at, :datetime),
              Trains::DTO::Field.new(:updated_at, :datetime)
            ],
            version: 7.0
          ),
          Trains::DTO::Migration.new(
            table_name: 'Group',
            modifier: :add_column,
            fields: [
              Trains::DTO::Field.new(:name, :string)
            ],
            version: 7.0
          ),
          Trains::DTO::Migration.new(
            table_name: 'Group',
            modifier: :change_table,
            fields: [
              Trains::DTO::Field.new(:title, :remove),
              Trains::DTO::Field.new(%i[name whatup], :rename)
            ],
            version: 7.0
          ),
          Trains::DTO::Migration.new(
            table_name: 'Group',
            modifier: :rename_column,
            fields: [
              Trains::DTO::Field.new(:whatup, :name)
            ],
            version: 7.0
          ),
          Trains::DTO::Migration.new(
            table_name: 'Group',
            modifier: :remove_column,
            fields: [
              Trains::DTO::Field.new(:name, nil)
            ],
            version: 7.0
          )
        ]
      )
    end
  end
end
