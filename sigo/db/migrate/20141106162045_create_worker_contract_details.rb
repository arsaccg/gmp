class CreateWorkerContractDetails < ActiveRecord::Migration
  def change
    create_table :worker_contract_details do |t|
      t.integer :worker_id
      t.integer :worker_contract_id
      t.integer :concept_id
      t.float :amount

      t.timestamps
    end
  end
end
