class CreateClassroomsCourses < ActiveRecord::Migration
  def change
    create_table :classrooms_courses do |t|
      t.references :classroom, index: true
      t.references :course, index: true
    end
  end
end
