class CreateGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :groups do |t|
      t.string :title

      t.timestamps
    end
    add_column :groups, :name, :string
    add_index :groups, :title, unique: true
  end
end
