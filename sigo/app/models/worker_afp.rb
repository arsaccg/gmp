class WorkerAfp < ActiveRecord::Base
	belongs_to :worker, :touch => true
	belongs_to :afp
end
