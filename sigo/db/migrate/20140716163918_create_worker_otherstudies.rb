class CreateWorkerOtherstudies < ActiveRecord::Migration
  def change
    create_table :worker_otherstudies do |t|
    	t.string :study
      t.string :level

      t.timestamps
    end
  end
end
