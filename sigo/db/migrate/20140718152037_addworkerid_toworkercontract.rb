class AddworkeridToworkercontract < ActiveRecord::Migration
  def change
  	add_column :worker_contracts,:worker_id, :integer
  end
end
