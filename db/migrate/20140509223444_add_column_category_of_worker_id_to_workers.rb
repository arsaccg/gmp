class AddColumnCategoryOfWorkerIdToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :category_of_worker_id, :integer
  end
end
