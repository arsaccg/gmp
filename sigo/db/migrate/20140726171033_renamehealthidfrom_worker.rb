class RenamehealthidfromWorker < ActiveRecord::Migration
  def change
  	rename_column(:worker_healths, :health_id, :health_center_id)
  end
end
