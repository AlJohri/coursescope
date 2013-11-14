class CreateCourses < ActiveRecord::Migration
  def up
    create_table :courses, id: false do |t|
      t.integer :id, null: false
      t.string :title, null: false
      t.integer :number, null: false
      t.integer :section, null: false
      t.string :status, null: false
      t.string :category, null: false
      t.references :term, null: false, index: true
      t.string :department_id, null: false, index: true

      # Using t.references creates an integer column.
      # The primary key of the departments table is a string.
      # Therefore the foreign key department_id must also be a string.
      # TODO: override this method to allow for string foreign key
      # https://github.com/rails/rails/blob/88aa2efd692619e87eee88dfc48d608bea9bcdb4/activerecord/lib/active_record/connection_adapters/abstract/schema_definitions.rb#L421
      # t.references :department, null: false, index: true

      t.timestamps
    end
    execute "ALTER TABLE courses ADD PRIMARY KEY (id);"
  end

  def down
    drop_table :courses
  end  
end
