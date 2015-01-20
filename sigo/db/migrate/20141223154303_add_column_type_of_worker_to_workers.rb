class AddColumnTypeOfWorkerToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :type_of_worker_id, :integer
  end
end
