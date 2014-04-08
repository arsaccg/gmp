class StatePerOrderOfService < ActiveRecord::Base
	belongs_to :order_of_service
	belongs_to :user
end
