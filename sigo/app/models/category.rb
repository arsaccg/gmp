class Category < ActiveRecord::Base
	include ActiveModel::Validations
	
	has_many :articles

	#Validaciones
	include ActiveModel::Validations
	#validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
	validates :code, :uniqueness => { :message => "El código debe ser único."}

	def self.get_subcategories(code_category)
		return self.where("code LIKE ?", "#{code_category}__")
	end

	def self.get_specifics(code_subcategory)
		return self.where("code LIKE ?", "#{code_subcategory}__")
	end
  
end
