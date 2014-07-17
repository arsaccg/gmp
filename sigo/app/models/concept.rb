class Concept < ActiveRecord::Base
	has_many :concept_details
	accepts_nested_attributes_for :concept_details
end
