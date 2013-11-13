class CreateTerms < ActiveRecord::Migration
  def up
    create_table :terms, id: false do |t|
      t.integer :id
      t.string :title
      t.string :year

      t.timestamps
    end
    execute "ALTER TABLE terms ADD PRIMARY KEY(id);"
  end

  def down
  	drop_table :terms
  end

end
