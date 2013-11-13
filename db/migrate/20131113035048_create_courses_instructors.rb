class CreateCoursesInstructors < ActiveRecord::Migration
  def change
    create_table :courses_instructors, id: false do |t|
      t.references :course, index: true
      t.references :instructor, index: true
    end
  end
end
