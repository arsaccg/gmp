class Category < ActiveRecord::Base
	include ActiveModel::Validations
	
	has_many :articles
	has_many :subcategories

	# Validaciones
	validates :code, :uniqueness => { :message => "El código debe ser único"}
end
