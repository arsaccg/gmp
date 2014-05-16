class WorkingGroup < ActiveRecord::Base
	belongs_to :sector
	has_many :part_works
	has_many :part_people
end
