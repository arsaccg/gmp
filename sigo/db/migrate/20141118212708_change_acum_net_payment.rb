class ChangeAcumNetPayment < ActiveRecord::Migration
  def change
  	change_column :valuation_of_equipments, :accumulated_net_payment, :string
  end
end
