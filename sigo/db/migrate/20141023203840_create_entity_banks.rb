class CreateEntityBanks < ActiveRecord::Migration
  def change
    create_table :entity_banks do |t|
      t.integer :entity_id
      t.integer :bank_id
      t.integer :money_id
      t.string :account_type
      t.string :account_number
      t.string :account_detraction
      t.string :cci

      t.timestamps
    end
  end
end
