class AddCamposmigrationToscValuation < ActiveRecord::Migration
  def change
  	add_column :sc_valuations, :accumulated_valuation, :integer
  	add_column :sc_valuations, :accumulated_initial_amortization_number, :integer
  	add_column :sc_valuations, :accumulated_bill, :integer
  	add_column :sc_valuations, :accumulated_billigv, :integer
  	add_column :sc_valuations, :accumulated_totalbill, :integer
  	add_column :sc_valuations, :accumulated_retention, :integer
  	add_column :sc_valuations, :accumulated_detraction, :integer
  	add_column :sc_valuations, :accumulated_guarantee_fund1, :integer
  	add_column :sc_valuations, :accumulated_guarantee_fund2, :integer
  	add_column :sc_valuations, :accumulated_equipment_discount, :integer
  	add_column :sc_valuations, :accumulated_net_payment, :integer
  end
end
