class EntityPerTypeEntity < ActiveRecord::Base
	belongs_to :entity
	belongs_to :type_entity
end