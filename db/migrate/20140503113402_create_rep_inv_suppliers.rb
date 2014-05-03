class CreateRepInvSuppliers < ActiveRecord::Migration
  def change
    create_table :rep_inv_suppliers, :id => false, :primary_key => {:user => :id} do |t|
      t.integer :user
      t.integer :id
      t.string :name

      t.timestamps
    end
  end
end
