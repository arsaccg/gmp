# enconding: utf-8
class Article < ActiveRecord::Base
	has_many :deliver_orders
  
	belongs_to :category  
	belongs_to :type_of_article
  
	belongs_to :unit_of_measurement#, :through => :article_unit_of_measurements
	#accepts_nested_attributes_for :unit_of_measurements

	#Validaciones
	include ActiveModel::Validations
	#validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
	validates :code, :uniqueness => { :message => "El código debe ser único."}
end
