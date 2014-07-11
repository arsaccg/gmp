class TypeOfBookWork < ActiveRecord::Base
	has_and_belongs_to_many :book_works
end
