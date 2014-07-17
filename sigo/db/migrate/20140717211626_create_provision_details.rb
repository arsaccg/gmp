class CreateProvisionDetails < ActiveRecord::Migration
  def change
    create_table :provision_details do |t|
      t.integer :provision_id
      t.integer :order_detail_id
      t.string :type_of_order
      t.integer :account_accountant_id
      t.integer :amount
      t.float :unit_price_igv

      t.timestamps
    end
  end
end
