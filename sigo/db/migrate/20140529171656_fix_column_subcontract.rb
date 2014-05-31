class FixColumnSubcontract < ActiveRecord::Migration
  def change
  	rename_column :subcontract_equipment_advances, :subcontract_id, :subcontract_equipment_id
  end
end
