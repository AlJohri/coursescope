class CreateCourses < ActiveRecord::Migration
  def up
    create_table :courses, id: false do |t|
      t.integer :id, null: false
      t.string :title, null: false
      t.integer :number, null: false
      t.integer :section, null: false
      t.string :status
      t.string :type
      t.references :term, null: false
      t.references :department, null: false

      t.timestamps
    end
    execute "ALTER TABLE courses ADD PRIMARY KEY (id);"
    add_index :courses, :term
    add_index :courses, :department
  end

  def down
    drop_table :courses
  end  
end
