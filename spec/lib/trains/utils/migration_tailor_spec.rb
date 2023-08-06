# frozen_string_literal: true

describe Trains::Utils::MigrationTailor do
  context 'when migrations create_table, add_column' do
    let(:models_from_schema) do
      {
        'Post' => Trains::DTO::Model.new(
          name: 'Post',
          fields: [
            Trains::DTO::Field.new(:name, :string)
          ],
          version: 6.3
        )
      }
    end
    let(:create_add_migs) do
      [
        Trains::DTO::Migration.new(
          table_name: 'Post',
          modifier: :create_table,
          fields: [
            Trains::DTO::Field.new(:title, :string),
            Trains::DTO::Field.new(:more, :text)
          ],
          version: 5.2
        ),
        Trains::DTO::Migration.new(
          table_name: 'Post',
          modifier: :add_column,
          fields: [
            Trains::DTO::Field.new(:user_name, :string)
          ],
          version: 7.1
        )
      ]
    end

    it 'creates a model and adds a column to it' do
      models = Trains::Utils::MigrationTailor.stitch(models_from_schema,
                                                     create_add_migs)
      expect(models).to eq(
        {
          'Post' =>
        Trains::DTO::Model.new(
          name: 'Post',
          fields: [
            Trains::DTO::Field.new(:name, :string),
            Trains::DTO::Field.new(:title, :string),
            Trains::DTO::Field.new(:more, :text),
            Trains::DTO::Field.new(:user_name, :string)
          ],
          version: 6.3
        )
        }
      )
    end
  end

  context 'when migrations create_table, remove_column' do
    let(:create_remove_migs) do
      [
        Trains::DTO::Migration.new(
          table_name: 'Post',
          modifier: :create_table,
          fields: [
            Trains::DTO::Field.new(:title, :string),
            Trains::DTO::Field.new(:more, :text)
          ],
          version: 5.2
        ),
        Trains::DTO::Migration.new(
          table_name: 'Post',
          modifier: :remove_column,
          fields: [
            Trains::DTO::Field.new(:title, nil)
          ],
          version: 7.1
        )
      ]
    end

    it 'creates a model and removes title column from it' do
      models = Trains::Utils::MigrationTailor.stitch(create_remove_migs)
      expect(models).to eq(
        {
          'Post' =>
        Trains::DTO::Model.new(
          name: 'Post',
          fields: [
            Trains::DTO::Field.new(:more, :text)
          ],
          version: 5.2,
          removed_columns: [:title]
        )
        }
      )
    end
  end

  context 'when migrations create_table, change_column' do
    let(:create_change_migs) do
      [
        Trains::DTO::Migration.new(
          table_name: 'Post',
          modifier: :create_table,
          fields: [
            Trains::DTO::Field.new(:title, :string),
            Trains::DTO::Field.new(:more, :string)
          ],
          version: 5.2
        ),
        Trains::DTO::Migration.new(
          table_name: 'Post',
          modifier: :change_column,
          fields: [
            Trains::DTO::Field.new(:more, :text)
          ],
          version: 7.1
        )
      ]
    end

    it 'creates a model and removes title column from it' do
      models = Trains::Utils::MigrationTailor.stitch(create_change_migs)
      expect(models).to eq(
        {
          'Post' =>
        Trains::DTO::Model.new(
          name: 'Post',
          fields: [
            Trains::DTO::Field.new(:title, :string),
            Trains::DTO::Field.new(:more, :text)
          ],
          version: 5.2
        )
        }
      )
    end
  end

  context 'Given migrations with rename and remove column' do
    let(:migs_with_rename) do
      [
        Trains::DTO::Migration.new(
          table_name: 'Group',
          modifier: :create_table,
          fields: [
            Trains::DTO::Field.new(:id, :bigint),
            Trains::DTO::Field.new(:title, :string),
            Trains::DTO::Field.new(:age, :integer),
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
            Trains::DTO::Field.new(:age, :alive_since)
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
        )
      ]
    end

    it 'generates models with renamed fields' do
      models = Trains::Utils::MigrationTailor.stitch(migs_with_rename)
      expect(models).to eq(
        {
          'Group' => Trains::DTO::Model.new(
            name: 'Group',
            version: 7.0,
            fields: [
              Trains::DTO::Field.new(:id, :bigint),
              Trains::DTO::Field.new(:created_at, :datetime),
              Trains::DTO::Field.new(:updated_at, :datetime),
              Trains::DTO::Field.new(:alive_since, :integer),
              Trains::DTO::Field.new(:name, :string)
            ],
            renamed_columns: [
              Trains::DTO::Rename.new(:name, :whatup),
              Trains::DTO::Rename.new(:age, :alive_since),
              Trains::DTO::Rename.new(:whatup, :name)
            ],
            removed_columns: %i[title]
          )
        }
      )
    end
  end
end
