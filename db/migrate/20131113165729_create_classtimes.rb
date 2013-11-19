class CreateClasstimes < ActiveRecord::Migration
  def change
    create_table :classtimes do |t|
      t.references :course, null: false, index: true
      t.references :classroom, null: false, index: true
      t.time :start_time 
      t.time :end_time
      t.integer :days, null: false

      t.timestamps
    end
  end
end
