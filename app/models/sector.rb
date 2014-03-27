# enconding: utf-8
class Sector < ActiveRecord::Base
	has_many :deliver_orders

	#Validaciones
	include ActiveModel::Validations
	#validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
	validates :code, :uniqueness => { :message => "El código debe ser único."}
end
