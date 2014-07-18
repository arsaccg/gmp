class AddcontractNameToworkercontract < ActiveRecord::Migration
  def change
  	add_column :worker_contracts,:typeofcontract, :string
  	add_column :worker_contracts,:end_date_2, :date
  end
end
