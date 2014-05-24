class PartPerson < ActiveRecord::Base
  has_many :part_person_details
  belongs_to :cost_center
  belongs_to :working_group
  accepts_nested_attributes_for :part_person_details, :allow_destroy => true

end
