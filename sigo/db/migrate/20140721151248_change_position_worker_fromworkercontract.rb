class ChangePositionWorkerFromworkercontract < ActiveRecord::Migration
  def change
  	change_column :worker_contracts, :charge_id, :integer
  end
end
