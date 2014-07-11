class CreateTypeOfWorkReports < ActiveRecord::Migration
  def change
  	if !table_exists? :type_of_work_reports
	    create_table :type_of_work_reports do |t|
	      t.string :name
	      t.string :preffix
	      t.integer :cost_center_id

	      t.timestamps
	    end
	  end
  end
end
