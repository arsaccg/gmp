class Concept < ActiveRecord::Base
	has_many :concept_details
	
	has_and_belongs_to_many :category_of_workers
end
