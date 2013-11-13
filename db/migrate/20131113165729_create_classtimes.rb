class CreateClasstimes < ActiveRecord::Migration
  def change
    create_table :classtimes do |t|
      t.references :course, null: false
      t.references :classroom, null: false
      t.time :start, null: false
      t.time :end, null: false
      t.integer :days, null: false

      t.timestamps
    end
    add_index :classtimes, :course
    add_index :classtimes, :classroom
  end
end
