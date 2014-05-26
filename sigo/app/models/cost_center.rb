class CostCenter < ActiveRecord::Base
	
	has_many :delivery_orders
	has_many :purchase_orders
	has_many :order_of_services
	has_many :entities
	has_many :stock_inputs
	has_many :warehouses
	has_many :center_of_attentions
	has_many :working_groups
	has_many :sectors
	has_many :workers
	has_many :subcontract_inputs
	has_many :subcontracts
	has_many :subcontract_equipments
	has_many :part_works
	has_many :part_people
	has_many :part_of_equipments

  has_many :items
  has_many :budgets

	belongs_to :company

	# Access
	has_and_belongs_to_many :users

	default_scope { where(status: "A").order("name ASC") }

	# Validaciones
	include ActiveModel::Validations
	validates :code, :uniqueness => { :scope => [:company_id, :status], :message => "El código debe ser único."}

	after_validation :do_activecreate, on: [:create]
  
    def do_activecreate
      self.status = "A"
    end

end