class AddItembybudgetIdToMeasuredBySector < ActiveRecord::Migration
  def change
    add_column :measured_by_sectors, :itembybudget_id, :integer
  end
end
