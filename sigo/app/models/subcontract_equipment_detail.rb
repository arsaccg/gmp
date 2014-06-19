class SubcontractEquipmentDetail < ActiveRecord::Base
	has_one :rental_type
	belongs_to :article
	belongs_to :subcontract_equipment

	def self.getOwnArticles(word, cost_center_id)
    @cost_center = CostCenter.find(get_company_cost_center('cost_center'))
    @name = @cost_center.name.delete("^a-zA-Z0-9-").gsub("-","_").downcase.tr(' ', '_')
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT a.id, a.name, u.name, a.code 
      FROM articles_from_"+@name+" a, unit_of_measurements u
      AND a.code LIKE '03%'
      AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' )
      AND u.id = a.unit_of_measurement_id
      LIMIT #{display_length}
      OFFSET #{pager_number}
    ")

    return mysql_result
  end
end


