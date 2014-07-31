class WorkerContract < ActiveRecord::Base
	belongs_to :worker
	belongs_to :article
	belongs_to :contract_type
end
