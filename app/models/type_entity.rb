class TypeEntity < ActiveRecord::Base
	has_many :entity_per_type_entities
	has_many :entities, :through => :entity_per_type_entities
end
