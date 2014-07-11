class TypeOfCompany < ActiveRecord::Base
	has_and_belongs_to_many :of_companies
end
