class CreateSubcontractEquipmentDetails < ActiveRecord::Migration
  def change
    create_table :subcontract_equipment_details do |t|
      t.integer :article_id
      t.string :description
      t.string :brand
      t.string :series
      t.string :model
      t.date :date_in
      t.integer :year
      t.float :price_no_igv
      t.integer :rental_type_id
      t.string :minimum_hours
      t.integer :amount_hours
      t.float :contracted_amount

      t.timestamps
    end
  end
end
