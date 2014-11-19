class SubcontractEquipmentAdvance < ActiveRecord::Base
	belongs_to :subcontract_equipment, :touch => true
end
