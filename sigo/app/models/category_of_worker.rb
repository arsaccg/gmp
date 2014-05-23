class CategoryOfWorker < ActiveRecord::Base
	belongs_to :unit_of_measurement
	belongs_to :article
end
