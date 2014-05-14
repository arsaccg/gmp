class AddColumnCodeToCostCenters < ActiveRecord::Migration
  def change
    add_column :cost_centers, :code, :string
  end
end
