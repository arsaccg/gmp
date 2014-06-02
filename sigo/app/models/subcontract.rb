class Subcontract < ActiveRecord::Base
  self.inheritance_column = nil
  has_many :subcontract_details
  has_many :subcontract_advances
  belongs_to :cost_center
  belongs_to :entity
  accepts_nested_attributes_for :subcontract_details, :allow_destroy => true
  accepts_nested_attributes_for :subcontract_advances, :allow_destroy => true

  def self.getOwnArticles(word)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT DISTINCT a.id, a.code, a.name, a.unit_of_measurement_id, u.symbol
      FROM inputbybudgetanditems ibi, budgets b, articles a, unit_of_measurements u 
      WHERE b.id = ibi.budget_id
      AND b.type_of_budget =0
      AND b.cost_center_id =5
      AND ibi.article_id IS NOT NULL 
      AND ibi.article_id = a.id
      AND a.code LIKE '04%'
      AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' ) 
      AND a.unit_of_measurement_id = u.id
    ")

    return mysql_result
  end
end
