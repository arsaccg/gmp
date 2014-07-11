class TypeOfReceivedLetter < ActiveRecord::Base
	has_and_belongs_to_many :received_letters
end
