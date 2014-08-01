class CreatePaymentOrders < ActiveRecord::Migration
  def change
    create_table :payment_orders do |t|
      t.integer :provision_id
      t.float :net_pay
      t.float :igv

      t.timestamps
    end
  end
end
