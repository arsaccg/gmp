class WorkerCenterOfStudy < ActiveRecord::Base
	belongs_to :worker, :touch => true
end
