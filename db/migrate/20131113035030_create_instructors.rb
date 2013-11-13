class CreateInstructors < ActiveRecord::Migration
  def change
    create_table :instructors do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email
      t.string :website
      t.string :type

      t.timestamps
    end
    add_index :instructors, [:first_name, :last_name], :unique => true
  end
end
