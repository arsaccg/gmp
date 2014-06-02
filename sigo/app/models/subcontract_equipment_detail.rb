class SubcontractEquipmentDetail < ActiveRecord::Base
	has_one :rental_type
	belongs_to :article
	belongs_to :subcontract_equipment

	def self.getOwnArticles(word)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT DISTINCT a.id, a.name
      FROM inputbybudgetanditems ibi, budgets b, articles a
      WHERE b.id = ibi.budget_id
      AND b.type_of_budget =0
      AND b.cost_center_id =5
      AND ibi.article_id IS NOT NULL 
      AND ibi.article_id = a.id
      AND a.code LIKE '03%'
      AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' )
    ")

    return mysql_result
  end
end
