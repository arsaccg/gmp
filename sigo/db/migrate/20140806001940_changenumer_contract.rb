class ChangenumerContract < ActiveRecord::Migration
  def change
  	change_column :worker_contracts, :numberofcontract,  :string
  end
end
