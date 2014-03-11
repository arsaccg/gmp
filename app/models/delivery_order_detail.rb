class DeliveryOrderDetail < ActiveRecord::Base
	belongs_to :delivery_order
	belongs_to :sector
	belongs_to :phase
	belongs_to :article
	belongs_to :unit_of_measurement
	belongs_to :center_of_attention
end
