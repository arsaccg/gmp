class DeliveryOrderDetail < ActiveRecord::Base
	belongs_to :delivery_order
	belongs_to :sector
	belongs_to :phase
	belongs_to :article
	belongs_to :unit_of_measurement
	belongs_to :center_of_attention
	belongs_to :cost_center
	has_many :purchase_order_details

	belongs_to :rep_inv_article, :foreign_key => 'article_id'
end
