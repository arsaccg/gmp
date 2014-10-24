class Bank < ActiveRecord::Base
	has_many :worker_details
	has_many :entity_banks
end
