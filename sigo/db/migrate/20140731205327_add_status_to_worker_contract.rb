class AddStatusToWorkerContract < ActiveRecord::Migration
  def change
    add_column :worker_contracts, :status, :integer
  end
end
