class CreateCostCenterDetails < ActiveRecord::Migration
  def change
    create_table :cost_center_details do |t|
      t.string :name
      t.string :entity
      t.string :consortium
      t.date :call_date
      t.integer :snip_code 
      t.integer :process_number
      t.date :good_pro_date
      t.float :referential_value
      t.float :earned_value
      t.float :direct_cost
      t.float :general_cost
      t.float :utility
      t.float :IGV
      t.date :contract_sign_date
      t.integer :contract_number
      t.date :land_delivery_date
      t.date :direct_advanced_payment_date
      t.integer :cost_center_id
      t.timestamps
    end
  end
end
