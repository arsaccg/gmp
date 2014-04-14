class Entity < ActiveRecord::Base

	has_many :purchase_orders
	has_many :order_of_services
	#has_many :entity_per_type_entities, :dependent => :destroy
	has_and_belongs_to_many :type_entities#, :through => :entity_per_type_entities

	accepts_nested_attributes_for :type_entities, :allow_destroy => true
end
