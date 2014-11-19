class WorkerHealth < ActiveRecord::Base
	belongs_to :worker, :touch => true
	belongs_to :health_center
end
