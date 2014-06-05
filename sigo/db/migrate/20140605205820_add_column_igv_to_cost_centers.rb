class AddColumnIgvToCostCenters < ActiveRecord::Migration
  def change
    add_column :cost_centers, :igv, :float
  end
end
