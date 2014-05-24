class Article < ActiveRecord::Base
	has_many :deliver_orders
  	has_many :subcontract_details
  	has_many :subcontract_equipment_details
  	has_many :part_work_details
  	has_many :category_of_worker
  	has_many :workers
  	has_one :subcontract_input
	belongs_to :specific
	belongs_to :type_of_article
	belongs_to :unit_of_measurement#, :through => :article_unit_of_measurements
	#accepts_nested_attributes_for :unit_of_measurements
	belongs_to :rep_inv_article, :foreign_key => 'id'

	#Validaciones
	include ActiveModel::Validations
	#validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
	validates :code, :uniqueness => { :message => "El código debe ser único."}

	def self.find_article(id)
		return self.find(id)
	end
end
