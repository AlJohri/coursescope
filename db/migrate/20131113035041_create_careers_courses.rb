class CreateCareersCourses < ActiveRecord::Migration
  def change
    create_table :careers_courses, id: false do |t|
      t.references :career, null: false, index: true
      t.references :course, null: false, index: true
    end
  end
end
