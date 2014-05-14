class CreateSuppliers < ActiveRecord::Migration
  def change
    create_table :suppliers do |t|
      t.string :ruc
      t.string :name
      t.string :address
      t.string :phone
    end
  end
end
