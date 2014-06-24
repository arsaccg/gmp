class PartWork < ActiveRecord::Base
	has_many :part_work_details
	belongs_to :cost_center
	belongs_to :working_group
	belongs_to :sector
	accepts_nested_attributes_for :part_work_details, :allow_destroy => true

	def self.getOwnArticles(word, name)
    
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT DISTINCT a.id, a.name
      FROM articles_from_"+name+" a
      WHERE a.code LIKE '04%'
      AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' )
    ")
    return mysql_result
  end
end



