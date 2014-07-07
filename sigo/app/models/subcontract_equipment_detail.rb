class SubcontractEquipmentDetail < ActiveRecord::Base
	has_one :rental_type
	belongs_to :article
	belongs_to :subcontract_equipment

	def self.getOwnArticles(word, name)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT a.id, a.name, u.name, a.code 
      FROM articles_from_cost_center_" + name.to_s + " a, unit_of_measurements u
      WHERE a.code LIKE '03%'
      AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' )
      AND u.id = a.unit_of_measurement_id
      GROUP BY a.code
    ")
    return mysql_result
  end
end


