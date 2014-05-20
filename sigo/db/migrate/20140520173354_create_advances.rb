class CreateAdvances < ActiveRecord::Migration
  def change
    create_table :advances do |t|
      t.string :advance_type
      t.integer :advance_number
      t.float :advance_direct_cost_percent
      t.float :amount
      t.integer :cost_center_id

      t.timestamps
    end
  end
end
