class AddAfPtypetoWorker < ActiveRecord::Migration
  def change
  	add_column :workers,:afptype, :string
  	add_column :workers,:afpnumber, :string
  end
end
