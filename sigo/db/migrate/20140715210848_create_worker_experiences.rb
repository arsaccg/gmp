class CreateWorkerExperiences < ActiveRecord::Migration
  def change
    create_table :worker_experiences do |t|
    	t.string :businessname
      t.string :businessaddress
      t.string :title
			t.float :salary
      t.string :bossincharge
      t.string :exitreason
			t.date :start_date
			t.date :end_date
      t.timestamps
    end
  end
end
