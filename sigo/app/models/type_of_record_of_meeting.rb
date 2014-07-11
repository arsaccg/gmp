class TypeOfRecordOfMeeting < ActiveRecord::Base
	has_and_belongs_to_many :record_of_meetings
end
