class ChangeCuspPtoAfpdetails < ActiveRecord::Migration
  def change
  	remove_column :workers, :afpnumber
  end
end
