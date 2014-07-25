class WorkerHealth < ActiveRecord::Base
	belongs_to :worker
	belongs_to :health_center
end
