class AddPaymentDateToAdvances < ActiveRecord::Migration
  def change
    add_column :advances, :payment_date, :date
  end
end
