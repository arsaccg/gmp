class CreatePartWorkerDetails < ActiveRecord::Migration
  def change
    create_table :part_worker_details do |t|
      t.integer :worker_id
      t.integer :phase_id
      t.integer :sector_id
    	t.string :assistance
      t.string :reason_of_lack
      t.integer :working_group_id
      t.integer :cost_center_id
      t.integer :company_id
      t.integer :part_worker_id

      t.timestamps
    end
  end
end
