class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses, id: false do |t|
      t.integer :id
      t.string :title
      t.integer :number
      t.integer :section
      t.datetime :start
      t.datetime :end
      t.integer :days
      t.string :status
      t.string :type
      t.references :term, index: true
      t.references :department, index: true

      t.timestamps
    end
    execute "ALTER TABLE courses ADD PRIMARY KEY (id);"
  end
end
