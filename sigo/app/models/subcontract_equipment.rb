class SubcontractEquipment < ActiveRecord::Base
  has_many :subcontract_equipment_details
  has_many :part_of_equipments
  belongs_to :cost_center
  belongs_to :entity
end
