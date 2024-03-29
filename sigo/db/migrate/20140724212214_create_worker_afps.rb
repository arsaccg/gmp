class CreateWorkerAfps < ActiveRecord::Migration
  def change
    if !table_exists? :worker_afps
      create_table :worker_afps do |t|
      	t.integer :afp_id
        t.string :afptype
        t.string :afpnumber
        t.integer :worker_id
        t.date :start_date
        t.date :end_date

        t.timestamps
      end
    end
  end
end
