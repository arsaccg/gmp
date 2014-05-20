class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :item_code
      t.integer :project_code
      t.string :wbs_parent_code
      t.string :budget_code
      t.string :description
      t.string :own_code
      t.integer :level
      t.string :unity_code
      t.integer :deleted
      t.integer :cost_center_id

      t.timestamps
    end
  end
end
