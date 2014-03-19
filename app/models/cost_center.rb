# enconding: urf-8
class CostCenter < ActiveRecord::Base
	
	has_many :delivery_orders
	
	# Validaciones
	include ActiveModel::Validations
	#validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
	validates :code, :uniqueness => { :message => "El código debe ser único."}

end