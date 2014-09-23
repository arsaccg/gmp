class PartPersonDetail < ActiveRecord::Base
	belongs_to :part_person, :touch => true
	belongs_to :sector
	belongs_to :worker
	belongs_to :phase
end
