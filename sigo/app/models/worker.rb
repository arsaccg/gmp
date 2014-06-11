class Worker < ActiveRecord::Base
	has_many :part_person_details
	has_many :worker_details
	has_many :part_of_equipments
	belongs_to :entity
	belongs_to :cost_center
	belongs_to :position_worker
	belongs_to :article

	accepts_nested_attributes_for :worker_details, :allow_destroy => true

	def self.find_name_front_chief(front_chief_id)
	  return Worker.find(front_chief_id).first_name + ' ' + Worker.find(front_chief_id).second_name + ' ' + Worker.find(front_chief_id).paternal_surname + ' ' + Worker.find(front_chief_id).maternal_surname
	end

	def self.find_name_master_builder(master_builder_id)
	  return Worker.find(master_builder_id).first_name + ' ' + Worker.find(master_builder_id).second_name + ' ' + Worker.find(master_builder_id).paternal_surname + ' ' + Worker.find(master_builder_id).maternal_surname
	end

	state_machine :state, :initial => :disapproved do

    event :approve do
      transition :disapproved => :approved
    end

  end
end
