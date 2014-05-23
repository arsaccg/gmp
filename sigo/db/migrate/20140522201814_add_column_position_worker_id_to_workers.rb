class AddColumnPositionWorkerIdToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :position_worker_id, :integer
  end
end
