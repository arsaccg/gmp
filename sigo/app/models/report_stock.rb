class ReportStock < ActiveRecord::Base
  def self.get_articles(cost_center_id, display_length, pager_number, keyword = '')
    result = Array.new
    if keyword != '' && pager_number != 'NaN'
      article = ActiveRecord::Base.connection.execute("
        SELECT art.code, art.name, SUM(sid.amount)
        FROM articles art, stock_inputs si, stock_input_details sid 
        WHERE si.id = sid.stock_input_id
        AND sid.article_id = art.id
        AND si.input = 1 
        AND si.cost_center_id = " + cost_center_id.to_s + " 
        AND (art.code LIKE '%" + keyword + "%' OR art.name LIKE '%" + keyword + "%') 
        GROUP BY art.code ASC 
        LIMIT " + display_length + " 
        OFFSET " + pager_number
      )
    elsif pager_number != 'NaN'
      article = ActiveRecord::Base.connection.execute("
        SELECT art.code, art.name, SUM(sid.amount)
        FROM articles art, stock_inputs si, stock_input_details sid 
        WHERE si.id = sid.stock_input_id
        AND sid.article_id = art.id
        AND si.input = 1 
        AND si.cost_center_id = " + cost_center_id.to_s + " 
        GROUP BY art.code ASC 
        LIMIT " + display_length + " 
        OFFSET " + pager_number
      )
    else
      article = ActiveRecord::Base.connection.execute("
        SELECT art.code, art.name, SUM(sid.amount)
        FROM articles art, stock_inputs si, stock_input_details sid 
        WHERE si.id = sid.stock_input_id
        AND sid.article_id = art.id
        AND si.input = 1 
        AND si.cost_center_id = " + cost_center_id.to_s + " 
        GROUP BY art.code ASC 
        LIMIT " + display_length
      )
    end

    article.each do |art|
      result << [
        art[0], 
        art[1],
        art[2]
      ]
    end

    return result
  end
end
