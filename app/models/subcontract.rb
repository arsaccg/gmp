class Subcontract < ActiveRecord::Base
	has_and_belongs_to_many :working_group
end
