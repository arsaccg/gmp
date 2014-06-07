class SubcontractEquipmentDetail < ActiveRecord::Base
	has_one :rental_type
	belongs_to :article
	belongs_to :subcontract_equipment

	def self.getOwnArticles(word, cost_center_id)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT DISTINCT a.id, a.name, u.name
      FROM inputbybudgetanditems ibi, budgets b, articles a, unit_of_measurements u
      WHERE b.id = ibi.budget_id
      AND b.type_of_budget =0
      AND b.cost_center_id = #{cost_center_id}
      AND ibi.article_id IS NOT NULL 
      AND ibi.article_id = a.id
      AND a.code LIKE '03%'
      AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' )
      AND u.id = a.unit_of_measurement_id
    ")

    return mysql_result
  end
end
