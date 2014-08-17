class AddColumnsToCostCenters < ActiveRecord::Migration
  def change
    add_column :cost_centers, :district, :string
    add_column :cost_centers, :province, :string
    add_column :cost_centers, :department, :string 
  end
end
