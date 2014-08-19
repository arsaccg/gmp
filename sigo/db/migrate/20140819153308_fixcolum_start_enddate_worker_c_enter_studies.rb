class FixcolumStartEnddateWorkerCEnterStudies < ActiveRecord::Migration
  def change
    change_column :worker_center_of_studies, :start_date,  :integer
    change_column :worker_center_of_studies, :end_date,  :integer  	
  end
end
