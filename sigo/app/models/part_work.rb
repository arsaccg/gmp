class PartWork < ActiveRecord::Base
	has_many :part_work_details
	belongs_to :cost_center
	belongs_to :working_group
	belongs_to :sector
	accepts_nested_attributes_for :part_work_details, :allow_destroy => true

	def self.getOwnArticles(word, cost_center_id)
    @cost_center = CostCenter.find(get_company_cost_center('cost_center'))
    @name = @cost_center.name.delete("^a-zA-Z0-9-").gsub("-","_").downcase.tr(' ', '_')
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT a.id, a.name
      FROM articles_from_"+@name+" a
      AND a.code LIKE '04%'
      AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' )
      LIMIT #{display_length}
      OFFSET #{pager_number}
    ")
    return mysql_result
  end
end



