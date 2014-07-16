class Provision < ActiveRecord::Base
	belongs_to :cost_center
	belongs_to :document_provision
end
