class Subcontract < ActiveRecord::Base
  self.inheritance_column = nil
  has_many :subcontract_details
  has_many :subcontract_advances
  belongs_to :cost_center
  belongs_to :entity
  accepts_nested_attributes_for :subcontract_details, :allow_destroy => true
  accepts_nested_attributes_for :subcontract_advances, :allow_destroy => true
end
