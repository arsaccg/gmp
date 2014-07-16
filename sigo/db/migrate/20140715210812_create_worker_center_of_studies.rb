class CreateWorkerCenterOfStudies < ActiveRecord::Migration
  def change
    create_table :worker_center_of_studies do |t|
    	t.string :name
      t.string :profession
      t.string :title
			t.string :numberoftuition
			t.date :start_date
			t.date :end_date
      t.timestamps
    end
  end
end
