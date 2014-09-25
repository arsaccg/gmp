class WorkerDetail < ActiveRecord::Base
	belongs_to :worker, :touch => true
	belongs_to :bank
end
