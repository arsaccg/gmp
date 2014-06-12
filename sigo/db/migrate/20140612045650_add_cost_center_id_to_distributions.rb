class AddCostCenterIdToDistributions < ActiveRecord::Migration
  def change
    add_column :distributions, :cost_center_id, :integer
  end
end
