class Subcontract < ActiveRecord::Base
  self.inheritance_column = nil
  has_many :subcontract_details
  has_many :subcontract_advances
  belongs_to :cost_center
  belongs_to :entity
  accepts_nested_attributes_for :subcontract_details, :allow_destroy => true
  accepts_nested_attributes_for :subcontract_advances, :allow_destroy => true

  def self.getOwnArticles(word, cost_center_id)
    @cost_center = CostCenter.find(get_company_cost_center('cost_center'))
    @name = @cost_center.name.delete("^a-zA-Z0-9-").gsub("-","_").downcase.tr(' ', '_')
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT a.id, a.code, a.name, a.unit_of_measurement_id, u.symbol
      FROM articles_from_"+@name+" a, unit_of_measurements u
      AND a.code LIKE '04%'
      AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' )
      AND u.id = a.unit_of_measurement_id
      LIMIT #{display_length}
      OFFSET #{pager_number}
    ")

    return mysql_result
  end
end