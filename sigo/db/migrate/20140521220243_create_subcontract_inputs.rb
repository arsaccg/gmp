class CreateSubcontractInputs < ActiveRecord::Migration
  def change
    create_table :subcontract_inputs do |t|
      t.integer :article_id
      t.float :price

      t.timestamps
    end
  end
end
