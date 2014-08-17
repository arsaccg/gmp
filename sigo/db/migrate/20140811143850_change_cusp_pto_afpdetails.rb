class ChangeCuspPtoAfpdetails < ActiveRecord::Migration
  def change
    add_column :worker_afps, :afpnumber, :string
  	remove_column :workers, :afpnumber
  end
end
