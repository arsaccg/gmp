class CreateScheduleOfWorkers < ActiveRecord::Migration
  def change
    create_table :schedule_of_workers do |t|
      t.date :start_date
      t.date :end_date
      t.string :state
      t.integer :number_workers
      t.integer :cost_center_id

      t.timestamps
    end
  end
end
