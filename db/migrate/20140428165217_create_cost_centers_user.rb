class CreateCostCentersUser < ActiveRecord::Migration
  def change
    create_table :cost_centers_users do |t|
      t.integer :cost_center_id
      t.integer :user_id
      t.timestamps
    end
  end
end
