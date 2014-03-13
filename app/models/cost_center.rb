class CostCenter < ActiveRecord::Base
	include ActiveModel::Validations

	has_many :deliver_order_details
	#validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }

	# Validaciones
	validates :code, :uniqueness => { :message => "El código debe ser único"}

end