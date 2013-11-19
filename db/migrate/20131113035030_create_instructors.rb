class CreateInstructors < ActiveRecord::Migration
  def change
    create_table :instructors do |t|
      t.string :first_name, null: false
      t.string :middle_name
      t.string :last_name, null: false
      t.string :category, null: false      
      t.string :email
      t.string :website

      t.timestamps
    end
    add_index :instructors, [:first_name, :middle_name, :last_name], :unique => true
  end
end
