class CreateProvisions < ActiveRecord::Migration
  def change
    create_table :provisions do |t|
      t.integer :document_provision_id
      t.string :number_document_provision
      t.date :accounting_date
      t.string :series
      t.integer :entity_id
      t.integer :purchase_order_id
      t.text :description

      t.timestamps
    end
  end
end
