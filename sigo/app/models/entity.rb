class Entity < ActiveRecord::Base

	has_many :purchase_orders
	has_many :order_of_services
	has_many :subcontracts
	has_many :subcontract_equipments
	belongs_to :cost_center
	#has_many :entity_per_type_entities, :dependent => :destroy
	has_and_belongs_to_many :type_entities#, :through => :entity_per_type_entities

	accepts_nested_attributes_for :type_entities, :allow_destroy => true

	include ActiveModel::Validations
	validates :ruc, :uniqueness => { :message => "El RUC debe ser único."}, :allow_blank => true, :case_sensitive => false
	validates :dni, :uniqueness => { :message => "El DNI debe ser único."}, :allow_blank => true, :case_sensitive => false

	def self.find_name_executor(executor_id)
		return Entity.find(executor_id).name
	end
end
