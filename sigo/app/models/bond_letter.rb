class BondLetter < ActiveRecord::Base
  has_many :bond_letter_details
  has_one :advance
end
