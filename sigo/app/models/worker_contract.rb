class WorkerContract < ActiveRecord::Base
	belongs_to :worker
	belongs_to :charge
end
