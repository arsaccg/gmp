class Phase < ActiveRecord::Base
	has_many :deliver_orders

	def self.get_subphases(phase_code)
	  subphase = Phase.where("code LIKE ? AND category = ?","#{phase_code}%","subphase")
	  return subphase
	end
end
