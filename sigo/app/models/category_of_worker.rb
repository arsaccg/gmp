class CategoryOfWorker < ActiveRecord::Base
	belongs_to :unit_of_measurement
	belongs_to :article
	belongs_to :category

	has_many :category_of_workers_concepts
	accepts_nested_attributes_for :category_of_workers_concepts, :allow_destroy => true

	# has_and_belongs_to_many :concepts
end
