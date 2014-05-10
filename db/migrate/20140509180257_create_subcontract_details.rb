class CreateSubcontractDetails < ActiveRecord::Migration
  def change
    create_table :subcontract_details do |t|
      t.integer :article_id
      t.integer :amount
      t.float :unit_price
      t.float :partial
      t.text :description

      t.timestamps
    end
  end
end
