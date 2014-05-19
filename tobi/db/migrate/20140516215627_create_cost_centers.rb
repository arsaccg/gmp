class CreateCostCenters < ActiveRecord::Migration
  def change
    create_table :cost_centers do |t|
      t.string :name
      t.float :total_amount
      t.float :direct_cost_amount
      t.float :general_cost_amount 
      t.float :utility_amount
      t.float :advance_payment_percent 
      t.float :coaching_granted_percent 
      t.float :igv
      t.integer :deleted
      t.timestamps
    end
  end
end
