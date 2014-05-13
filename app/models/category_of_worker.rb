class CategoryOfWorker < ActiveRecord::Base
	belongs_to :unit_of_measurement
	has_many :workers
end
