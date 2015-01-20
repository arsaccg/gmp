# encoding: utf-8
class Phase < ActiveRecord::Base
  has_many :delivery_orders
  has_many :warehouse_orders
  has_many :part_person_details
  has_many :part_of_equipment_details
  has_many :subcontract_details
  has_many :wbsitems
  has_many :general_expenses
  
  #Validaciones
  include ActiveModel::Validations
  #validates :code, :uniqueness => { :scope => :name, :message => "El código debe ser único" }
  validates :code, :uniqueness => { :message => "El código debe ser único."}

  def self.get_subphases(phase_code)
    subphase = Phase.where("code LIKE ? AND category = ?","#{phase_code}%","subphase")
    return subphase
  end

  def self.getSpecificPhases(cost_center_id)
    mysql_result = Phase.find(:all, :select =>"DISTINCT p.id, p.name, p.code", :from => 'wbsitems w, phases p, general_expenses ge', :conditions => ["w.cost_center_id = ? AND w.phase_id = p.id OR ge.phase_id = p.id AND ge.cost_center_id = ?", cost_center_id, cost_center_id], :order => "p.code ASC")
    return mysql_result
  end
end
