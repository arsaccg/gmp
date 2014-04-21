# enconding: utf-8
class CostCenter < ActiveRecord::Base
	
	has_many :delivery_orders
	has_many :purchase_orders
	has_many :order_of_services
	belongs_to :company
	default_scope { where(status: "A").order("name ASC") }

	# Validaciones
	include ActiveModel::Validations
	validates :code, :uniqueness => { :scope => [:company_id, :status], :message => "El código debe ser único."}

	after_validation :do_activecreate, on: [:create]
  
    def do_activecreate
      self.status = "A"
    end

end