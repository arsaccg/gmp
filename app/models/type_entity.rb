class TypeEntity < ActiveRecord::Base

	#has_many :entity_per_type_entities, :dependent => :destroy
	has_and_belongs_to_many :entities#, :through => :entity_per_type_entities
end
