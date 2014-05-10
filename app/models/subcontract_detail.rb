class SubcontractDetail < ActiveRecord::Base
	belongs_to :subcontract
	has_many :articles
end
