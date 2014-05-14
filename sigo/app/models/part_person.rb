class PartPerson < ActiveRecord::Base
	has_many :part_person_details
	accepts_nested_attributes_for :part_person_details, :allow_destroy => true
end
