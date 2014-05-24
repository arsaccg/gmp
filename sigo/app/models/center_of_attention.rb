class CenterOfAttention < ActiveRecord::Base
	has_many :delivery_order_detail
	belongs_to :cost_center
end
