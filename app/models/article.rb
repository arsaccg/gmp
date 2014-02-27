class Article < ActiveRecord::Base
	has_many :deliver_orders
end
