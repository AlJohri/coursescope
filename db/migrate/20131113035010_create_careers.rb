class CreateCareers < ActiveRecord::Migration
  def up
    create_table :careers, id: false do |t|
      t.string :id, null: false
      t.string :title, null: false

      t.timestamps
    end
    execute "ALTER TABLE careers ADD PRIMARY KEY (id);"
  end

  def down
    drop_table :careers
  end
end
