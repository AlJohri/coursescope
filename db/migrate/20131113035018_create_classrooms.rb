class CreateClassrooms < ActiveRecord::Migration
  def change
    create_table :classrooms do |t|
      t.string :title, null: false

      t.timestamps
    end
    add_index :classrooms, :title, unique: true
  end
end
