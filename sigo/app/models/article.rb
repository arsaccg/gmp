# encoding: utf-8
class Article < ActiveRecord::Base
  
    include ActiveModel::Validations 
	
    has_many :deliver_orders
    
  	has_many :subcontract_details
  	has_many :subcontract_equipment_details
  	has_many :part_work_details
  	has_many :category_of_worker
  	has_many :workers
	  has_many :part_work_details
    
    
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

	def self.getSpecificArticles(cost_center_id, display_length, pager_number)
      mysql_result = ActiveRecord::Base.connection.execute("
        SELECT DISTINCT a.id, a.code, toa.name, c.name, a.name, a.description, u.name
        FROM inputbybudgetanditems ibi, budgets b, articles a, unit_of_measurements u, type_of_articles toa, categories c
        WHERE b.id = ibi.budget_id
        AND b.type_of_budget =0
        AND b.cost_center_id = #{cost_center_id}
        AND ibi.article_id IS NOT NULL 
        AND ibi.article_id = a.id
        AND a.unit_of_measurement_id = u.id
        AND a.category_id = c.id 
      	AND u.id = a.unit_of_measurement_id
        AND toa.id = a.type_of_article_id
      	LIMIT #{display_length}
      	OFFSET #{pager_number}
      ")

      return mysql_result
  end

  def self.getSpecificArticlesforStockOutputs(cost_center_id)
      mysql_result = ActiveRecord::Base.connection.execute("
        SELECT DISTINCT a.id, a.code, toa.name, c.name, a.name, a.description, u.name
        FROM delivery_orders do, delivery_order_details dod, purchase_order_details pod, articles a, unit_of_measurements u, type_of_articles toa, categories c 
        WHERE dod.id = pod.delivery_order_detail_id
        AND pod.received = 1
        AND dod.delivery_order_id=do.id 
        AND do.cost_center_id = #{cost_center_id}
        AND dod.article_id = a.id
        AND a.unit_of_measurement_id = u.id
        AND a.category_id = c.id 
        AND u.id = a.unit_of_measurement_id
        AND toa.id = a.type_of_article_id
      ")
      return mysql_result
  end

  def self.getArticles(word)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT DISTINCT a.id, a.code, a.name, a.unit_of_measurement_id, u.symbol
      FROM articles a, unit_of_measurements u 
      WHERE (a.code LIKE '04%' || a.code LIKE '03%' || a.code LIKE '02%')
      AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' ) 
      AND a.unit_of_measurement_id = u.id
    ")
    return mysql_result
  end

end
