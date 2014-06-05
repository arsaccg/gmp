class CreateWeeklyWorkers < ActiveRecord::Migration
  def change
    create_table :weekly_workers do |t|
    	t.date :start_date
      t.date :end_date
      t.string :working_group

      t.timestamps
    end
  end
end
