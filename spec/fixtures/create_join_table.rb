class CreatePeople < ActiveRecord::Migration[7.0]
  def change
    create_join_table :statuses, :tags do |t|
      t.string :job
      t.text :bio

      t.timestamps
      t.index %i[tag_id status_id], unique: true
    end
  end
end
