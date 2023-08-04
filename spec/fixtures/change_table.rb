class ChangeTable < ActiveRecord::Migration[7.0]
  def change
    create_table :groups do |t|
      t.string :title

      t.timestamps
    end
    add_column :groups, :name, :string
    add_index :groups, :title, unique: true

    change_table :groups do |t|
      t.remove :title
      t.rename :name, :whatup
    end

    rename_column :groups, :whatup, :name
    remove_column :groups, :name
  end
end
