class DeliveryOrder < ActiveRecord::Base
	 
	has_many :state_per_order_details
	has_many :delivery_order_details

	belongs_to :user
	belongs_to :sector
	belongs_to :phase
	belongs_to :cost_center

	accepts_nested_attributes_for :delivery_order_details

	state_machine :state, :initial => :issued do
		event :revise do
			transition[:issued] => :revised
		end

		event :approve do
			transition[:revised] => :approved
		end
	end
	
end
