# enconding: utf-8
class CostCenter < ActiveRecord::Base
	
	has_many :delivery_orders
	has_many :purchase_orders
	has_many :order_of_services
	belongs_to :company
	# Validaciones
	include ActiveModel::Validations
	#validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
	validates :code, :uniqueness => { :message => "El código debe ser único."}

end