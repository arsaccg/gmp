class OrderOfServiceDetail < ActiveRecord::Base
	belongs_to :article
	belongs_to :sector
	belongs_to :phase
	belongs_to :unit_of_measurement
	belongs_to :order_of_service
	has_many :order_service_extra_calculations
end
