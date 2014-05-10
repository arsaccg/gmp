class CategoryOfWorker < ActiveRecord::Base
	belongs_to :unit_of_measurement
	has_one :worker
end
