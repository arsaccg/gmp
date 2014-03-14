class Category < ActiveRecord::Base
	include ActiveModel::Validations
	
	has_many :articles
	has_many :subcategories

	#Validaciones
	include ActiveModel::Validations
	#validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
	validates :code, :uniqueness => { :message => "El código debe ser único."}
end
