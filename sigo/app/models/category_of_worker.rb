class CategoryOfWorker < ActiveRecord::Base
	belongs_to :unit_of_measurement
	belongs_to :article
	belongs_to :category

	has_and_belongs_to_many :concepts
end
