class CreateEntityCostCenterDetails < ActiveRecord::Migration
  def change
    create_table :entity_cost_center_details do |t|
      t.integer :cost_center_detail_id
      t.integer :entity_id 
      t.integer :participation
      t.timestamps
    end
  end
end
