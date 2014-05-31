class CreateValuationOfEquipments < ActiveRecord::Migration
  def change
    create_table :valuation_of_equipments do |t|
    	t.string :name
      t.date :start_date
      t.date :end_date
      t.string :working_group
      t.float :valuation
      t.float :initial_amortization_number
      t.float :initial_amortization_percentage
      t.float :bill
      t.float :billigv
      t.float :totalbill
      t.float :retention
      t.float :detraction
      t.float :fuel_discount
      t.float :other_discount
      t.float :hired_amount
      t.float :advances
      t.float :accumulated_amortization
      t.float :balance
      t.float :net_payment
      t.float :accumulated_valuation
      t.float :accumulated_initial_amortization_number
      t.float :accumulated_bill
      t.float :accumulated_billigv
      t.float :accumulated_totalbill
      t.float :accumulated_retention
      t.float :accumulated_detraction
      t.float :accumulated_fuel_discount
      t.float :accumulated_other_discount
      t.float :accumulated_net_payment
      t.string :state
      t.timestamps
    end
  end
end
