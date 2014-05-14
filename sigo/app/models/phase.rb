class Phase < ActiveRecord::Base
	has_many :deliver_orders
	has_many :part_person_details
	#Validaciones
	include ActiveModel::Validations
	#validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
	validates :code, :uniqueness => { :message => "El código debe ser único."}

	def self.get_subphases(phase_code)
	  subphase = Phase.where("code LIKE ? AND category = ?","#{phase_code}%","subphase")
	  return subphase
	end
end
