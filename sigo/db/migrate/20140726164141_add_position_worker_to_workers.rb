class AddPositionWorkerToWorkers < ActiveRecord::Migration
  def change
  	remove_column :workers, :article_id
  end
end
