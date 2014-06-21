class WorkingGroup < ActiveRecord::Base
	has_many :part_works
	has_many :stock_outputs
	has_many :part_people
	has_many :part_of_equipment_details
	belongs_to :cost_center
	belongs_to :sector
	belongs_to :front_chief, :foreign_key => 'front_chief_id'
	belongs_to :master_builder, :foreign_key => 'master_builder_id'
	belongs_to :executor, :foreign_key => 'executor_id'
	default_scope { where(active: true).order("id ASC") }
	after_validation :do_activecreate, on: [:create]
  
	def do_activecreate
	self.active = true
	end

	def do_inactive
	self.active = false
	end
end
