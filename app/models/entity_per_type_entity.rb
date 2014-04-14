class EntityPerTypeEntity < ActiveRecord::Base
	belongs_to :entity
	belongs_to :type_entity

	validates_presence_of :entity
	validates_presence_of :type_entity

	accepts_nested_attributes_for :type_entity, :allow_destroy => true
end