class AddfieldToWorkerAndContracts < ActiveRecord::Migration
  def change
    add_column :workers, :afpnumber, :string
    add_column :worker_contracts, :contract_type_id, :integer
  end
end
