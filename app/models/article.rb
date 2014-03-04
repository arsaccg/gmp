class Article < ActiveRecord::Base
	has_many :deliver_orders
	belongs_to :category
	belongs_to :unit_of_measurement
end
