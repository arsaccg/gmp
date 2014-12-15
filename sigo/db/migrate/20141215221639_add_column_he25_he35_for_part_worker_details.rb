class AddColumnHe25He35ForPartWorkerDetails < ActiveRecord::Migration
  def change
  	add_column :part_worker_details, :he_25, :string
  	add_column :part_worker_details, :he_35, :string
  end
end
