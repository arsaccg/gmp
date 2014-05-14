class SubcontractDetail < ActiveRecord::Base
	belongs_to :subcontract
	belongs_to :article
end
