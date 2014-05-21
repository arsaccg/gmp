class PartOfEquipment < ActiveRecord::Base
	has_many :part_of_equipment_details
	belongs_to :subcontract_equipment
	belongs_to :worker
	accepts_nested_attributes_for :part_of_equipment_details, :allow_destroy => true
end
