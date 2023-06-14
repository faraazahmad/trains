class CreatePeople < ActiveRecord::Migration[7.0]
  def change
    create_table :people do |t|
      t.column :name, :string
      t.integer :age
      t.string :job
      t.text :bio

      t.timestamps
    end
  end
end
