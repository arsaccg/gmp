class DropIgvFromCostCenters < ActiveRecord::Migration
  def change
  	remove_column :cost_centers, :igv
  	remove_column :cost_centers, :overhead_percentage
  end
end
