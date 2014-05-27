class AddCostCenterIdToInputbybudgetanditems < ActiveRecord::Migration
  def change
    add_column :inputbybudgetanditems, :cost_center_id, :integer
  end
end
