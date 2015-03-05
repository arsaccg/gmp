class CreateBondLetters < ActiveRecord::Migration
  def change
    create_table :bond_letters do |t|
      t.integer :cost_center_id
      t.integer :issuer_entity_id
      t.integer :receptor_entity_id
      t.integer :concept
      t.integer :advance_id
      t.integer :status

      t.timestamps
    end
  end
end
