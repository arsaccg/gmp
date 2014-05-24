class SubcontractInput < ActiveRecord::Base
	belongs_to :article
	belongs_to :cost_center
end
