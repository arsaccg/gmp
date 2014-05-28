class CreateScValuations < ActiveRecord::Migration
  def change
    if !table_exists? :sc_valuations
      create_table :sc_valuations do |t|
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
        t.float :guarantee_fund1
        t.float :guarantee_fund2
        t.float :equipment_discount
        t.float :material_discount
        t.float :hired_amount
        t.float :advances
        t.float :accumulated_amortization
        t.float :balance
        t.float :net_payment
        t.timestamps
      end
    end
  end
end
