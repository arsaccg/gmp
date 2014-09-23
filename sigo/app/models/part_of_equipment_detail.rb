class PartOfEquipmentDetail < ActiveRecord::Base
	belongs_to :part_of_equipment, :touch => true
	belongs_to :working_group
	belongs_to :phase
	belongs_to :sector
end
