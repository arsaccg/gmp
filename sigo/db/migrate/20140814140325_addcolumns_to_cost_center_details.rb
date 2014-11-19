class AddcolumnsToCostCenterDetails < ActiveRecord::Migration
  def change
    remove_column :cost_centers, :district
    remove_column :cost_centers, :province
    remove_column :cost_centers, :department 
    add_column :cost_center_details, :district, :string
    add_column :cost_center_details, :province, :string
    add_column :cost_center_details, :department, :string 
  end
end
