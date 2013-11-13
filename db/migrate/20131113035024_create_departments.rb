class CreateDepartments < ActiveRecord::Migration
  def up
    create_table :departments, id: false do |t|
      t.string :id
      t.string :title

      t.timestamps
    end
    execute "ALTER TABLE departments ADD PRIMARY KEY (id);"
  end

  def down
  	drop_table :departments
  end

end
