class AddnumberofcontractToworkercontract < ActiveRecord::Migration
  def change
  	add_column :worker_contracts,:numberofcontract, :integer
  	add_column :workers,:typeofworker, :string
  end
end
