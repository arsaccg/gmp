class CreateWorkerContracts < ActiveRecord::Migration
  def change
    create_table :worker_contracts do |t|
    	t.string :position_of_worker
    	t.float :camp
    	t.float :destaque
    	t.float :salary
      t.float :regime
      t.integer :regime
      t.integer :days
      t.date :start_date
      t.date :end_date
      t.timestamps
    end
  end
end
