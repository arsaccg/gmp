class Worker < ActiveRecord::Base
	belongs_to :category_of_worker
	has_many :part_person_details
end
