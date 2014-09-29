class GeneralExpense < ActiveRecord::Base
  has_many :general_expense_details
  belongs_to :phase
  accepts_nested_attributes_for :general_expense_details, :allow_destroy => true

  def self.getOwnArticles(word)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT a.id, a.code, a.name, a.unit_of_measurement_id, u.symbol
      FROM articles a, unit_of_measurements u 
      WHERE ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' )
      AND a.unit_of_measurement_id = u.id
      GROUP BY a.code
    ")
    return mysql_result
  end  
end
