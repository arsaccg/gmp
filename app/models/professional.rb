class Professional < ActiveRecord::Base
	has_many :professional_certificate
	has_many :certificates, :through => :professional_certificate

	has_many :professional_training
	has_many :trainings, :through => :professional_training
end
