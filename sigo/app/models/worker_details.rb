class WorkerDetails < ActiveRecord::Base
	belongs_to :worker
	belongs_to :bank
end
