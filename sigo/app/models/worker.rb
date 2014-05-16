class Worker < ActiveRecord::Base
	belongs_to :category_of_worker
	has_many :part_person_details
	has_many :worker_details

	accepts_nested_attributes_for :worker_details, :allow_destroy => true
end
