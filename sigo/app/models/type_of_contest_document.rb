class TypeOfContestDocument < ActiveRecord::Base
	has_and_belongs_to_many :contest_documents
end
