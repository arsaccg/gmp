class CreateAmortizationByValorizations < ActiveRecord::Migration
  def change
    create_table :amortization_by_valorizations do |t|
      t.integer :code
      t.string :kind
      t.integer :valorization_id
      t.float :amount

      t.timestamps
    end
  end
end
