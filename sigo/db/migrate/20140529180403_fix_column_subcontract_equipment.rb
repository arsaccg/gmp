class FixColumnSubcontractEquipment < ActiveRecord::Migration
  def change
  	rename_column :subcontract_equipments, :type, :igv
  end
end
