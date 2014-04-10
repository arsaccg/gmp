class ProfessionalTraining < ActiveRecord::Base
	belongs_to :professional
	belongs_to :training
end
