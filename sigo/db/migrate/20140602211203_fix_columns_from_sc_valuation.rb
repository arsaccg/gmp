class FixColumnsFromScValuation < ActiveRecord::Migration
  def change
  	change_column :sc_valuations, :accumulated_valuation, :float
  	change_column :sc_valuations, :accumulated_initial_amortization_number, :float
  	change_column :sc_valuations, :accumulated_bill, :float
  	change_column :sc_valuations, :accumulated_billigv, :float
  	change_column :sc_valuations, :accumulated_totalbill, :float
  	change_column :sc_valuations, :accumulated_retention, :float
  	change_column :sc_valuations, :accumulated_detraction, :float
  	change_column :sc_valuations, :accumulated_guarantee_fund1, :float
  	change_column :sc_valuations, :accumulated_guarantee_fund2, :float
  	change_column :sc_valuations, :accumulated_equipment_discount, :float
  	change_column :sc_valuations, :accumulated_net_payment, :float
  end
end





	




	

