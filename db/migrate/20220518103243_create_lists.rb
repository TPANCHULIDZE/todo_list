class CreateLists < ActiveRecord::Migration[7.0]
  def change
    create_table :lists do |t|
      t.string :description
      t.datetime :start_date
      t.datetime :end_date
      t.integer :todo_id
      t.boolean :is_end
      t.timestamps null: false
    end
  end
end
