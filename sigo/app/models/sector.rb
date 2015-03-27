# encoding: utf-8
class Sector < ActiveRecord::Base
	has_many :delivery_orders
    has_many :warehouse_orders
	has_many :working_groups
	has_many :part_works
	has_many :part_person_details
	has_many :part_of_equipment_details
	belongs_to :cost_center

	has_many :measured_by_sectors
	#Validaciones
	#include ActiveModel::Validations
	#validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
	
	def self.getSubSectors(sector_code, cc)
	  return Sector.where("code LIKE '#{sector_code}__' AND cost_center_id = #{cc}")
	end
end
