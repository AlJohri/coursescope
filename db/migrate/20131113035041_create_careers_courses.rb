class CreateCareersCourses < ActiveRecord::Migration
  def change
    create_table :careers_courses, id: false do |t|
      t.references :career, index: true
      t.references :course, index: true
    end
  end
end