class CreateCoursesInstructors < ActiveRecord::Migration
  def change
    create_table :courses_instructors, id: false do |t|
      t.references :course, null: false, index: true
      t.references :instructor, null: false, index: true
    end
  end
end
