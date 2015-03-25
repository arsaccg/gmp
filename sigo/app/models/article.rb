# encoding: utf-8
class Article < ActiveRecord::Base
  
    include ActiveModel::Validations 
	
    has_many :delivery_orders
    has_many :warehouse_orders
  	has_many :subcontract_details
  	has_many :subcontract_equipment_details
  	has_many :part_work_details
  	has_many :category_of_worker
  	has_many :worker_contracts
	  has_many :part_work_details
    has_many :theoretical_values
    has_many :provision_direct_purchase_details
    
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

  def self.find_article_in_specific(id, cost_center_id)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT af.id, af.name, af.article_id, af.code, u.name
      FROM articles_from_cost_center_" + cost_center_id.to_s + " af, unit_of_measurements u
      WHERE af.unit_of_measurement_id = u.id
      AND af.id = " + id.to_s
    )

    return mysql_result
  end

  def self.find_articles_in_specific_table(cost_center_id, display_length, pager_number, keyword = '')
    if pager_number != 'NaN' && keyword != ''
      mysql_result = ActiveRecord::Base.connection.execute("
        SELECT especific.id, especific.code, toa.name, especific.name, especific.description, uom.name 
        FROM articles_from_cost_center_" + cost_center_id.to_s + " especific, type_of_articles toa, unit_of_measurements uom 
        WHERE especific.unit_of_measurement_id = uom.id 
        AND especific.type_of_article_id = toa.id
        AND (especific.name LIKE '%" + keyword + "%' OR especific.code LIKE '%" + keyword + "%')
        GROUP BY 2
        LIMIT " + display_length + "
        OFFSET " + pager_number + "
      ")
    elsif pager_number != 'NaN'
      mysql_result = ActiveRecord::Base.connection.execute("
        SELECT especific.id, especific.code, toa.name, especific.name, especific.description, uom.name 
        FROM articles_from_cost_center_" + cost_center_id.to_s + " especific, type_of_articles toa, unit_of_measurements uom 
        WHERE especific.unit_of_measurement_id = uom.id 
        AND especific.type_of_article_id = toa.id
        GROUP BY 2
        LIMIT " + display_length + "
        OFFSET " + pager_number + "
      ")
    elsif keyword != ''
      mysql_result = ActiveRecord::Base.connection.execute("
        SELECT especific.id, especific.code, toa.name, especific.name, especific.description, uom.name 
        FROM articles_from_cost_center_" + cost_center_id.to_s + " especific, type_of_articles toa, unit_of_measurements uom 
        WHERE especific.unit_of_measurement_id = uom.id 
        AND especific.type_of_article_id = toa.id
        AND especific.name LIKE '%" + keyword + "%' OR especific.code LIKE '%" + keyword + "%'
        GROUP BY 2
        LIMIT " + display_length + "
        OFFSET " + pager_number + "
      ")
    else
      mysql_result = ActiveRecord::Base.connection.execute("
        SELECT especific.id, especific.code, toa.name, especific.name, especific.description, uom.name 
        FROM articles_from_cost_center_" + name.to_s + " especific, type_of_articles toa, unit_of_measurements uom 
        WHERE especific.unit_of_measurement_id = uom.id 
        AND especific.type_of_article_id = toa.id
        GROUP BY 2
        LIMIT " + display_length
      )
    end

    return mysql_result
  end

  def self.find_specific_in_article(id, cost_center_id)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT af.id, af.name, af.article_id, af.code, u.name
      FROM articles_from_cost_center_"+cost_center_id.to_s+" af, unit_of_measurements u
      WHERE af.unit_of_measurement_id = u.id
      AND af.article_id =" + id.to_s + " 
    ")

    return mysql_result
  end

  def self.find_article_by_global_article(article_id, cost_center_id)
    name_article = ""
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT af.id, af.name, af.article_id, af.code, u.name
      FROM articles_from_cost_center_"+cost_center_id.to_s+" af, unit_of_measurements u
      WHERE af.unit_of_measurement_id = u.id
      AND af.id =" + article_id.to_s + " 
    ")

    mysql_result.each do |data|
      name_article = data[1]
    end

    return name_article
  end

  def self.find_article_by_global_article2(article_id, cost_center_id)
    name_article = ""
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT af.id, af.name, af.article_id, af.code, u.name
      FROM articles_from_cost_center_"+cost_center_id.to_s+" af, unit_of_measurements u
      WHERE af.unit_of_measurement_id = u.id
      AND af.id =" + article_id.to_s + " 
    ")

    mysql_result.each do |data|
      name_article = data[2]
    end

    return name_article
  end

  def self.find_article_global_by_specific_article(article_id, cost_center_id)
    name_article = ""
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT af.id, af.name, af.article_id, af.code, u.name
      FROM articles_from_cost_center_"+cost_center_id.to_s+" af, unit_of_measurements u
      WHERE af.unit_of_measurement_id = u.id
      AND af.id =" + article_id.to_s + " 
    ")

    mysql_result.each do |data|
      name_article = data[2]
    end

    return name_article
  end

  def self.find_article_global_by_specific_article2(article_id, cost_center_id)
    name_article = ""
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT af.id, af.name, af.article_id, af.code, u.name
      FROM articles_from_cost_center_"+cost_center_id.to_s+" af, unit_of_measurements u
      WHERE af.unit_of_measurement_id = u.id
      AND af.article_id =" + article_id.to_s + " 
    ")

    mysql_result.each do |data|
      name_article = data[0]
    end

    return name_article
  end

  def self.find_article_global_by_specific_article3(article_id, cost_center_id)
    name_article = ""
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT af.id, af.name, af.article_id, af.code, u.name
      FROM articles_from_cost_center_" + cost_center_id.to_s + " af, unit_of_measurements u
      WHERE af.unit_of_measurement_id = u.id
      AND af.article_id =" + article_id.to_s + " 
      LIMIT 1
    ")

    mysql_result.each do |data|
      name_article = data[0]
    end

    return name_article
  end

  def self.find_idarticle_global_by_specific_idarticle(specific_article_id, cost_center_id)
    article_data = Array.new
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT af.name, af.id, u.name, af.code, af.unit_of_measurement_id
      FROM articles af, unit_of_measurements u
      WHERE af.unit_of_measurement_id = u.id
      AND af.id =" + specific_article_id.to_s + " 
      LIMIT 1
    ")

    mysql_result.each do |data|
      article_data = [data[0], data[1], data[2], data[3], data[4]]
    end

    return article_data
  end

  def self.get_article_per_type(type_article, cost_center)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT af.id, af.name, af.code, af.article_id, af.unit_of_measurement_id, u.name
      FROM articles_from_cost_center_" + cost_center.to_s + " af, unit_of_measurements u
      WHERE af.code LIKE '#{type_article}%'
      AND af.unit_of_measurement_id = u.id
    ")
    return mysql_result
  end

  def self.get_article_todo_per_type_concat(type_article, word)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT af.id, af.code, af.name, af.unit_of_measurement_id, u.symbol
      FROM articles af
      INNER JOIN unit_of_measurements u ON af.unit_of_measurement_id = u.id
      WHERE af.code LIKE '#{type_article}%'
        AND Concat(af.code, ' ', af.name, ' ', u.symbol) LIKE '%#{word}%'
    ")
    return mysql_result
  end

  def self.get_article_todo_per_type(code, cost_center, type_article)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT af.id, af.name, af.code, af.unit_of_measurement_id, u.name
      FROM articles af, unit_of_measurements u
      WHERE ( af.code LIKE '#{code}%' OR af.name LIKE '%#{code}%' )
      AND af.code <= '#{type_article}99999999'
      AND af.unit_of_measurement_id = u.id
    ")
    return mysql_result
  end

	def self.getSpecificArticles(cost_center_id, display_length, pager_number)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT *
      FROM articles_from_cost_center_" + cost_center_id.to_s + " 
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
      WHERE (a.code LIKE '05%' || a.code LIKE '04%' || a.code LIKE '03%' || a.code LIKE '02%')
      AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' ) 
      AND a.unit_of_measurement_id = u.id
    ")
    return mysql_result
  end

  def self.getSpecificArticlesPerWarehouse(warehouse_id, word,idsn)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT a.id, a.code, a.name, u.name, SUM( sid.amount ) 
      FROM articles a, unit_of_measurements u, stock_inputs si, stock_input_details sid
      WHERE a.id = sid.article_id
      AND (a.code LIKE '%#{word}%' OR a.name LIKE '%#{word}%')
      AND si.input = 1
      AND si.id = sid.stock_input_id
      AND si.warehouse_id = #{warehouse_id}
      AND a.unit_of_measurement_id = u.id
      AND a.id NOT IN (#{idsn})
      GROUP BY a.code
    ")
    return mysql_result
  end

  def self.getSpecificArticlePerConsult(warehouse_id, article_id)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT a.id, a.code, a.name, u.name, SUM( sid.amount ) 
      FROM articles a, unit_of_measurements u, stock_inputs si, stock_input_details sid
      WHERE a.id = sid.article_id
      AND a.id = #{article_id}
      AND si.input =1
      AND si.id = sid.stock_input_id
      AND si.warehouse_id = #{warehouse_id}
      AND a.unit_of_measurement_id = u.id
      GROUP BY a.code
    ")
    return mysql_result
  end

  def self.getSpecificArticlesforStockOutputs2(warehouse_id,articles)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT a.id, a.code, toa.name, c.name, a.name, u.name, SUM(sid.amount)
      FROM articles a, unit_of_measurements u, type_of_articles toa, categories c, stock_inputs si, stock_input_details sid 
      WHERE a.id = sid.article_id 
      AND si.id = sid.stock_input_id 
      AND si.input = 1 
      AND si.warehouse_id = #{warehouse_id} 
      AND a.unit_of_measurement_id = u.id 
      AND a.category_id = c.id 
      AND toa.id = a.type_of_article_id
      AND a.id IN( #{articles} )
      GROUP BY a.code
    ")
    return mysql_result
  end

  def self.getSpecificArticlesforStockOutputs4(warehouse_id,article)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT SUM(sid.amount) AS 'salida'
      FROM articles a, unit_of_measurements u, type_of_articles toa, categories c, stock_inputs si, stock_input_details sid 
      WHERE a.id = sid.article_id 
      AND si.id = sid.stock_input_id 
      AND si.input = 0 
      AND si.status = 'A'
      AND si.warehouse_id = #{warehouse_id} 
      AND a.unit_of_measurement_id = u.id 
      AND a.category_id = c.id 
      AND toa.id = a.type_of_article_id
      AND a.id = #{article}
      GROUP BY a.code
    ")
    return mysql_result
  end

  def self.getSpecificArticlesforStockOutputs5(article)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT art.name, pod.unit_price
      FROM articles art, purchase_order_details pod, delivery_order_details dod
      WHERE pod.delivery_order_detail_id = dod.id
      AND dod.article_id = art.id
      AND dod.article_id IN( #{article} )
      AND pod.received = 1
      ORDER BY pod.created_at DESC
      LIMIT 2
    ")
    @totalprice = 0
    cont = 0
    mysql_result.each do |workerDetail|
      @totalprice += workerDetail[1]
      cont += 1
    end
    return @totalprice/cont
  end

end
