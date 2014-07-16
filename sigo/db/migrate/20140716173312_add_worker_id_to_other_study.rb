class AddWorkerIdToOtherStudy < ActiveRecord::Migration
  def change
  	unless column_exists? :worker_center_of_studies, :worker_id
      add_column :worker_center_of_studies, :worker_id, :integer
    end
  end
end
