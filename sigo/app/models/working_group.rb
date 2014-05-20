class WorkingGroup < ActiveRecord::Base
	belongs_to :sector
	has_many :part_works
	has_many :part_people
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