class PartWorkerDetail < ActiveRecord::Base
	belongs_to :part_worker
	belongs_to :sector
	belongs_to :worker
	belongs_to :phase
	belongs_to :working_group
end
