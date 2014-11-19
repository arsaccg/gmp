class ChangeAmazonTaxConditionFromCostCenterDetails < ActiveRecord::Migration
  def change
  	change_column :cost_center_details, :amazon_tax_condition,  :string, :default => "No aplica" 
  end
end
