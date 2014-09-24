class SubcontractDetail < ActiveRecord::Base
	belongs_to :subcontract, :touch => true
	belongs_to :article
	belongs_to :itembybudget
end
