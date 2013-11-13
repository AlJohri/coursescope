class CreateRequirements < ActiveRecord::Migration
  def change
    create_table :requirements do |t|
      t.references :course, index: true
      t.integer :prerequisite_id

      t.timestamps
    end
  end
end
