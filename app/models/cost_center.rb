class CostCenter < ActiveRecord::Base
	has_many :deliver_order_details
end
