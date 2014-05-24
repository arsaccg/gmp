
class Sector < ActiveRecord::Base
	has_many :deliver_orders
	has_many :working_groups
	has_many :part_works
	has_many :part_person_details
	has_many :part_of_equipment_details
	belongs_to :cost_center
	#Validaciones
	include ActiveModel::Validations
	#validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
	validates :code, :uniqueness => { :message => "El código debe ser único."}
	
	def self.getSubSectors(sector_code)
	  return Sector.where("code LIKE '#{sector_code}__'")
	end
end
