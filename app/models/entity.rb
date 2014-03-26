class Entity < ActiveRecord::Base
	has_many :entity_per_type_entities
	has_many :type_entities, :through => :entity_per_type_entities
end
