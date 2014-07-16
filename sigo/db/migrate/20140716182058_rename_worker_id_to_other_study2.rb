class RenameWorkerIdToOtherStudy2 < ActiveRecord::Migration
  def change
  	unless column_exists? :worker_otherstudies, :worker_id
      add_column :worker_otherstudies, :worker_id, :integer
    end
  end
end
