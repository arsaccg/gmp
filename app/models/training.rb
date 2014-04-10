class Training < ActiveRecord::Base
	has_many :professional_training
	has_many :professionals, :through => :professional_training
end
