class WarehouseOrder < ActiveRecord::Base
	has_many :warehouse_order_details
	accepts_nested_attributes_for :warehouse_order_details, :allow_destroy => true

end
