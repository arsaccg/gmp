class RenamePositionWorkerFromworkercontract < ActiveRecord::Migration
  def change
  	rename_column(:worker_contracts, :position_of_worker, :charge_id)
  end
end
