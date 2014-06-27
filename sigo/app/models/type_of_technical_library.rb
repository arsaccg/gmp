class TypeOfTechnicalLibrary < ActiveRecord::Base
	has_and_belongs_to_many :technical_libraries
end
