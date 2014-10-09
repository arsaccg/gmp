class SubcontractEquipment < ActiveRecord::Base
  has_many :subcontract_equipment_details
  has_many :part_of_equipments
  has_many :subcontract_equipment_advances
  has_many :valuation_of_equipments
  belongs_to :cost_center
  belongs_to :entity

  accepts_nested_attributes_for :subcontract_equipment_advances, :allow_destroy => true
end
