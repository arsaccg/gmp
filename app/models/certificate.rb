class Certificate < ActiveRecord::Base
	has_many :professional_certificate
	has_many :professionals, :through => :professional_certificate
end
