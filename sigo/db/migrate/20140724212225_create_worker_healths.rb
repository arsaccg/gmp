class CreateWorkerHealths < ActiveRecord::Migration
  def change
    create_table :worker_healths do |t|
    	t.integer :health_id
      t.integer :worker_id
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
