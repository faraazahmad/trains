class CreateChocolates < ActiveRecord::Migration[7.0]
  def change
    create_table :chocolates do |t|
      t.string :flavor
      t.references :box, null: false, foreign_key: true
      t.timestamps
    end
  end
end
