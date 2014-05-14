class StatePerOrderDetail < ActiveRecord::Base
	belongs_to :deliver_order
	belongs_to :user
end
