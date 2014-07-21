class Charge < ActiveRecord::Base
	belongs_to :certificate
	has_one :worker_contract
end
