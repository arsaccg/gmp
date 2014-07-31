class Entity < ActiveRecord::Base

	has_many :purchase_orders
	has_many :order_of_services
	has_many :subcontracts
	has_many :subcontract_equipments
	has_and_belongs_to_many :type_entities
	has_many :workers
	belongs_to :cost_center
	has_and_belongs_to_many :cost_center_details
	accepts_nested_attributes_for :type_entities, :allow_destroy => true

	include ActiveModel::Validations
	validates :ruc, :uniqueness => { :message => "El RUC debe ser unico."}, :allow_blank => true, :case_sensitive => false
	validates :dni, :uniqueness => { :message => "El DNI debe ser unico."}, :allow_blank => true, :case_sensitive => false

	def self.find_name_executor(executor_id)
		return Entity.find(executor_id).name
	end

	def self.find_name_supplier(supplier_id)
		return Entity.find(executor_id).name
	end
end
