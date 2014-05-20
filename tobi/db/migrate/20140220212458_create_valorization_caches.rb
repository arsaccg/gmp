class CreateValorizationCaches < ActiveRecord::Migration
  def change
    create_table :valorization_caches do |t|
      t.string :description
      t.string :und
      t.float :unit_price
      t.float :contract_price
      t.float :sumarized_before
      t.float :sumarized_actual
      t.float :credit_valorization
      t.float :advance

      t.timestamps
    end
  end
end
