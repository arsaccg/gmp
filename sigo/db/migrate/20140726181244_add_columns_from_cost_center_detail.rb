class AddColumnsFromCostCenterDetail < ActiveRecord::Migration
  def change
  	add_column :cost_center_details, :entity_id, :integer
  	add_column :cost_center_details, :amazon_tax_condition, :boolean
  	add_column :cost_center_details, :contractor_id, :integer
  	add_column :cost_center_details, :participation, :float
  	add_column :cost_center_details, :direct_advanced_form_date, :date
  	add_column :cost_center_details, :start_date_of_work, :date
  	add_column :cost_center_details, :procurement_system, :string
   	add_column :cost_center_details, :execution_term, :integer
   	add_column :cost_center_details, :supervision, :string
   	add_column :cost_center_details, :material_advanced_payment_date, :date
   		
  	remove_column :cost_center_details, :entity
    remove_column :cost_center_details, :consortium



  end
end
