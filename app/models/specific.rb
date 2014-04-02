# enconding: utf-8
class Specific < ActiveRecord::Base
	
	belongs_to :subcategory

	#Validaciones
	include ActiveModel::Validations
	#validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
	validates :code, :uniqueness => { :message => "El código debe ser único."}
end
