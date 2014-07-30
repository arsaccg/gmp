class CreateProvisionDirectPurchaseDetails < ActiveRecord::Migration
  def change
    create_table :provision_direct_purchase_details do |t|
      t.integer :article_id
      t.integer :sector_id
      t.integer :phase_id
      t.integer :amount
      t.float :price
      t.float :unit_price_before_igv
      t.boolean :igv
      t.float :quantity_igv
      t.float :discount_after
      t.float :discount_before
      t.text :description

      t.timestamps
    end
  end
end
