class Entity < ActiveRecord::Base
	has_many :purchase_orders
	has_many :entity_per_type_entities
	has_many :type_entities, :through => :entity_per_type_entities
	accepts_nested_attributes_for :entity_per_type_entities, :allow_destroy => true
end
