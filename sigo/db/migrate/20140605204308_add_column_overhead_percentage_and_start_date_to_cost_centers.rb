class AddColumnOverheadPercentageAndStartDateToCostCenters < ActiveRecord::Migration
  def change
    add_column :cost_centers, :overhead_percentage, :float
  end
end
