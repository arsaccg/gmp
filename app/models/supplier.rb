# enconding: urf-8
class Supplier < ActiveRecord::Base
	has_many :purchase_orders
	# Validaciones
	include ActiveModel::Validations
	#validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
	validates :ruc, :uniqueness => { :message => "El ruc debe ser único."}
end
