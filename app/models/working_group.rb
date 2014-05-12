class WorkingGroup < ActiveRecord::Base
	belongs_to :sector
	has_and_belongs_to_many :subcontract
end
