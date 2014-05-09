class Subcontract < ActiveRecord::Base
  has_many :subcontract_details
  accepts_nested_attributes_for :subcontract_details, :allow_destroy => true
end
