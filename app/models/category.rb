class Category < ActiveRecord::Base
	has_many :articles
	has_many :subcategory
end
