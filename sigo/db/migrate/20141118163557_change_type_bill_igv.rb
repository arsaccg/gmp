class ChangeTypeBillIgv < ActiveRecord::Migration
  def change
  	change_column :valuation_of_equipments, :billigv, :string
  	change_column :valuation_of_equipments, :accumulated_detraction, :string
  	change_column :valuation_of_equipments, :accumulated_retention, :string
  	change_column :valuation_of_equipments, :net_payment, :string
  end
end
