# enconding: urf-8
class MethodOfPayment < ActiveRecord::Base

	# Validaciones
	include ActiveModel::Validations
	#validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
	validates :name, :uniqueness => { :message => "El nombre debe ser único."}
end
