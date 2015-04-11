class WorkerContractDetail < ActiveRecord::Base
	belongs_to :worker_contract
	belongs_to :worker
end
