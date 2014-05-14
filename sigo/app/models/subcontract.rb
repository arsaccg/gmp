class Subcontract < ActiveRecord::Base
  self.inheritance_column = nil
  has_many :subcontract_details
  belongs_to :entity
  accepts_nested_attributes_for :subcontract_details, :allow_destroy => true
end
