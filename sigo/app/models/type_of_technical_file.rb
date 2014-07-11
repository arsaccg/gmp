class TypeOfTechnicalFile < ActiveRecord::Base
	has_and_belongs_to_many :technical_files
end
