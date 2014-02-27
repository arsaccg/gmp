class DeliveryOrder < ActiveRecord::Base
	has_many :state_per_order_details
	belongs_to :user
	belongs_to :sector
	belongs_to :phase
	belongs_to :cost_center
end
