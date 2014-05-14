class CreateWorkerDetails < ActiveRecord::Migration
  def change
    create_table :worker_details do |t|
      t.integer :bank_id
      t.string :account_number
      t.integer :worker_id

      t.timestamps
    end
  end
end
