class OrderOfServiceDetail < ActiveRecord::Base
	belongs_to :article
	belongs_to :sector
	belongs_to :phase
	belongs_to :unit_of_measurement
	belongs_to :order_of_service, :touch => true
	belongs_to :working_group
	has_many :order_service_extra_calculations

	accepts_nested_attributes_for :order_service_extra_calculations, :allow_destroy => true
end
