class AddfieldToWorkerAndContracts < ActiveRecord::Migration
  def change
    add_column :workers, :afpnumber, :string
  	remove_column :worker_afps, :afpnumber
    add_column :worker_contracts, :contract_type_id, :integer
  end
end
