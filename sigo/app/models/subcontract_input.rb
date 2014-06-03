class SubcontractInput < ActiveRecord::Base
	belongs_to :article
	belongs_to :cost_center

	def getOwnArticles(word, cost_center_id)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT DISTINCT a.id, a.name
      FROM inputbybudgetanditems ibi, budgets b, articles a, unit_of_measurements u 
      WHERE b.id = ibi.budget_id
      AND b.type_of_budget =0
      AND b.cost_center_id = #{cost_center_id}
      AND ibi.article_id IS NOT NULL 
      AND ibi.article_id = a.id
      AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' )
    ")

    return mysql_result
  end
end
