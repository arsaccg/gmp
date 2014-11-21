class ChangeTotalBill < ActiveRecord::Migration
  def change
  	change_column :valuation_of_equipments, :totalbill, :string
  end
end
