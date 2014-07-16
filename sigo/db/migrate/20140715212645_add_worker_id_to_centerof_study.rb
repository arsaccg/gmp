class AddWorkerIdToCenterofStudy < ActiveRecord::Migration
  def change
  	unless column_exists? :worker_center_of_studies, :worker_id
      add_column :worker_center_of_studies, :worker_id, :integer
    end
    unless column_exists? :worker_experiences, :worker_id
      add_column :worker_experiences, :worker_id, :integer
    end
    unless column_exists? :worker_familiars, :worker_id
      add_column :worker_familiars, :worker_id, :integer
    end
  end
end
