class CreateTypeOfWorkReportsWorkReports < ActiveRecord::Migration
  def change
  	if !table_exists? :type_of_work_reports_work_reports
	    create_table :type_of_work_reports_work_reports do |t|
	      t.integer :type_of_work_report_id
	      t.integer :work_report_id

	      t.timestamps
	    end
	  end
  end
end
