# encoding: utf-8
class Phase < ActiveRecord::Base
  has_many :deliver_orders
  has_many :part_person_details
  has_many :part_of_equipment_details
  has_many :wbsitems
  
  #Validaciones
  include ActiveModel::Validations
  #validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
  validates :code, :uniqueness => { :message => "El código debe ser único."}

  def self.get_subphases(phase_code)
    subphase = Phase.where("code LIKE ? AND category = ?","#{phase_code}%","subphase")
    return subphase
  end

  def self.getSpecificPhases(cost_center_id)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT DISTINCT a.id, a.code, toa.name, c.name, a.name, a.description, u.name
      FROM inputbybudgetanditems ibi, budgets b, articles a, unit_of_measurements u, type_of_articles toa, categories c
      WHERE b.id = ibi.budget_id
      AND b.type_of_budget =0
      AND b.cost_center_id = #{cost_center_id}
      AND ibi.article_id IS NOT NULL 
      AND ibi.article_id = a.id
      AND a.unit_of_measurement_id = u.id
      AND a.category_id = c.id 
      AND u.id = a.unit_of_measurement_id
    ")

    return mysql_result
  end
end
