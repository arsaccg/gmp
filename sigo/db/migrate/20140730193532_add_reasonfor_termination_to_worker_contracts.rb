class AddReasonforTerminationToWorkerContracts < ActiveRecord::Migration
  def change
    add_column :worker_contracts, :reason_for_termination, :string
  end
end
