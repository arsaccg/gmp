class WarehouseOrderDetail < ActiveRecord::Base
	belongs_to :warehouse_order
	has_many :articles
end