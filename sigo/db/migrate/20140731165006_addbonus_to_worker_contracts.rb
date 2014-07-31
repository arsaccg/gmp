class AddbonusToWorkerContracts < ActiveRecord::Migration
  def change
    add_column :worker_contracts, :viatical, :float
    add_column :worker_contracts, :bonus, :float
  	change_column :worker_contracts, :regime, :string
  end
end
