class PaymentOrder < ActiveRecord::Base
  belongs_to :provision

  def self.get_tobi_codes article_ids, cost_center_id
    names_category = Array.new
    code_category = ActiveRecord::Base.connection.execute("
      SELECT c.code, c.name 
      FROM articles_from_cost_center_" + cost_center_id.to_s + " af, categories c 
      WHERE af.id IN (" + article_ids.join(',').to_s + ")
      AND af.category_id = c.id 
      GROUP BY af.code"
    ).first[0][0..3]

    mysql = ActiveRecord::Base.connection.execute("
      SELECT name
      FROM categories
      WHERE code LIKE '" + code_category.to_s + "'"
    ).first
    if !names_category.include? mysql
      names_category << mysql[0]
    end
    return names_category
  end

  def self.get_amount_feo_by_code_phase(code, budget_id)
    ActiveRecord::Base.connection.execute("select get_amount_feo_by_code('"+code.to_s+"', "+budget_id.to_s+")").first[0]
  end
end
