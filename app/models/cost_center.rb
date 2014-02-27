class CostCenter < ActiveRecord::Base
	has_many :deliver_orders
end
