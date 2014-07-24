class MeasuredBySector < ActiveRecord::Base

	belongs_to :sector
	belongs_to :item
	
end
