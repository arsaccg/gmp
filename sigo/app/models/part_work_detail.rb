class PartWorkDetail < ActiveRecord::Base
	belongs_to :part_work, :touch => true
	belongs_to :article
	belongs_to :itembybudget
end
