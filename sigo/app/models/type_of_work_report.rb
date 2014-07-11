class TypeOfWorkReport < ActiveRecord::Base
	has_and_belongs_to_many :work_reports
end
