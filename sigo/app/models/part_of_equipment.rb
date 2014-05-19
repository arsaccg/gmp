class PartOfEquipment < ActiveRecord::Base
	has_many :part_of_equipment_details
	accepts_nested_attributes_for :part_of_equipment_details, :allow_destroy => true
end
