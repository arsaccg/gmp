class Input < ActiveRecord::Base
  has_many :input_units
  
  accepts_nested_attributes_for :input_units
end
