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
      SELECT DISTINCT p.id, p.name
      FROM wbsitems w, phases p
      WHERE w.cost_center_id = #{cost_center_id}
      AND w.phase_id = p.id
      AND w.phase_id IS NOT NULL 
    ")

    return mysql_result
  end
end
