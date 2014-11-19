class CreateTypeWorkdaysWorkers < ActiveRecord::Migration
  def change
  	if !table_exists? :type_workdays_workers
	    create_table :type_workdays_workers do |t|
	      t.integer :worker_id
	      t.integer :type_workday_id
	    end
	  end
  end
end
