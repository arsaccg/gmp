class Subcontract < ActiveRecord::Base
  self.inheritance_column = nil
  has_many :subcontract_details
  has_many :subcontract_advances
  belongs_to :cost_center
  belongs_to :entity
  accepts_nested_attributes_for :subcontract_details, :allow_destroy => true
  accepts_nested_attributes_for :subcontract_advances, :allow_destroy => true

  def self.getOwnArticles(word, name)
    
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT DISTINCT a.id, a.code, a.name, a.unit_of_measurement_id, u.symbol
      FROM articles_from_"+name+" a, unit_of_measurements u
      WHERE a.code LIKE '04%'
      AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' )
      AND u.id = a.unit_of_measurement_id
    ")

    return mysql_result
  end
end