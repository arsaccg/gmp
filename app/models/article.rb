class Article < ActiveRecord::Base
	has_many :deliver_orders
	belongs_to :category
	has_many :article_unit_of_measurements#, :through => :article_unit_of_measurements
	#accepts_nested_attributes_for :unit_of_measurements
end
