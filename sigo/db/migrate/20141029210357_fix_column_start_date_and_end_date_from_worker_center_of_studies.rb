class FixColumnStartDateAndEndDateFromWorkerCenterOfStudies < ActiveRecord::Migration
  def change
    change_column :worker_center_of_studies, :start_date,  :date
    change_column :worker_center_of_studies, :end_date,  :date
  end
end
