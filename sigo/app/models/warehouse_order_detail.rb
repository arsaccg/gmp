class WarehouseOrderDetail < ActiveRecord::Base
	belongs_to :warehouse_order
	belongs_to :article
	belongs_to :sector
	belongs_to :phase
end