class AddColumbLockedToValuationOfEquipments < ActiveRecord::Migration
  def change
    add_column :valuation_of_equipments, :locked, :boolean
  end
end
