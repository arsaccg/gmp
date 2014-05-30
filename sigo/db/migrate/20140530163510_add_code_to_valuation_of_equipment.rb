class AddCodeToValuationOfEquipment < ActiveRecord::Migration
  def change
    add_column :valuation_of_equipments, :code, :string
  end
end
