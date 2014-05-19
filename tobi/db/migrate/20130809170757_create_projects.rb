class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
    	t.string :custom_code
    	t.string :name, :null => false, :default => "Untitled"
    	t.float :total_amount
    	t.float :direct_cost_amount
    	t.float :general_cost_amount
    	t.float :utility_amount
    	t.float :advance_payment_percent
    	t.float :coaching_granted_percent
    	t.integer :status_flag
    	t.integer :manager_id
    	t.string  :period


      t.timestamps
    end
  end
end
