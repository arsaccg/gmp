class MethodOfPayment < ActiveRecord::Base
	has_many :purchase_orders
	has_many :order_of_services
	# Validaciones
	include ActiveModel::Validations
	#validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
	validates :name, :uniqueness => { :message => "El nombre debe ser único."}
end
