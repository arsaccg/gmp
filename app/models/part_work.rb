class PartWork < ActiveRecord::Base
	has_many :part_work_details
	accepts_nested_attributes_for :part_work_details, :allow_destroy => true
end
