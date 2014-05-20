# enconding: utf-8
class Subcategory < ActiveRecord::Base
	
	belongs_to :category
	has_many :specifics

	#Validaciones
	include ActiveModel::Validations
	#validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
	validates :code, :uniqueness => { :message => "El código debe ser único."}
end