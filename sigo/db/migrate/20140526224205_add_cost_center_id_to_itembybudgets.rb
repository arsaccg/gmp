class AddCostCenterIdToItembybudgets < ActiveRecord::Migration
  def change
    add_column :itembybudgets, :cost_center_id, :integer
  end
end
