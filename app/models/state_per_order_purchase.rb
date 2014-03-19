class StatePerOrderPurchase < ActiveRecord::Base
	belongs_to :purchase_order
	belongs_to :user
end
