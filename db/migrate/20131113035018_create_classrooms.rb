class CreateClassrooms < ActiveRecord::Migration
  def change
    create_table :classrooms do |t|
      t.string :title, null: false, index: true, unique: true

      t.timestamps
    end
  end
end
