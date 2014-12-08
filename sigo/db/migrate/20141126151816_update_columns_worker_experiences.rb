class UpdateColumnsWorkerExperiences < ActiveRecord::Migration
  def change
	change_column :worker_experiences, :start_date, :date
	change_column :worker_experiences, :end_date, :date	
  end
end
