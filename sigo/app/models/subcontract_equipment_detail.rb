class SubcontractEquipmentDetail < ActiveRecord::Base
	has_one :rental_type
	belongs_to :article
	belongs_to :subcontract_equipment
end
