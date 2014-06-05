class Article < ActiveRecord::Base
  
    include ActiveModel::Validations 
	
    has_many :deliver_orders
    
  	has_many :subcontract_details
  	has_many :subcontract_equipment_details
  	has_many :part_work_details
  	has_many :category_of_worker
  	has_many :workers
	  has_many :part_work_details
    
  	has_one :subcontract_input
    
    has_many :inputbybudgetanditems
  	belongs_to :category
  	belongs_to :type_of_article
  	belongs_to :unit_of_measurement
    
  	belongs_to :rep_inv_article, :foreign_key => 'id'

  	#Validaciones
    
  	validates :code, :uniqueness => { :message => "El código debe ser único."}

  	def self.find_article(id)
  		return self.find(id)
  	end
    
end
