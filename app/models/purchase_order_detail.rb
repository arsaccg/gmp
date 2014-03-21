class PurchaseOrderDetail < ActiveRecord::Base
	belongs_to :delivery_order_detail
	belongs_to :purchase_order
	belongs_to :user
end
