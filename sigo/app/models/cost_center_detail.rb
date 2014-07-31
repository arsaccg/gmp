class CostCenterDetail < ActiveRecord::Base
	belongs_to :cost_center
	has_many :entity_cost_center_details
	accepts_nested_attributes_for :entity_cost_center_details,
	  :allow_destroy => true
end
