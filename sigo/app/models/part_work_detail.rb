class PartWorkDetail < ActiveRecord::Base
	belongs_to :part_work
	belongs_to :article
end
