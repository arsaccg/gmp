class AddColumnCostCenterIdToProvisions < ActiveRecord::Migration
  def change
    add_column :provisions, :cost_center_id, :integer
  end
end
