class ChangeColumnCompanyToCostCenterFromPartWorker < ActiveRecord::Migration
  def change
  	rename_column :part_workers, :company_id, :cost_center_id
  end
end
