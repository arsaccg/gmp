class SubcontractEquipment < ActiveRecord::Base
  has_many :subcontract_equipment_details
  belongs_to :entity
end
