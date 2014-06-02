class PartWork < ActiveRecord::Base
	has_many :part_work_details
	belongs_to :cost_center
	belongs_to :working_group
	belongs_to :sector
	accepts_nested_attributes_for :part_work_details, :allow_destroy => true

	def self.getOwnArticles(word)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT DISTINCT a.id, a.name
      FROM inputbybudgetanditems ibi, budgets b, articles a, unit_of_measurements u 
      WHERE b.id = ibi.budget_id
      AND b.type_of_budget =0
      AND b.cost_center_id =5
      AND ibi.article_id IS NOT NULL 
      AND ibi.article_id = a.id
      AND a.code LIKE '04%'
      AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' )
    ")

    return mysql_result
  end
end
