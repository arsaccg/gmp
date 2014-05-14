class ProfessionalCertificate < ActiveRecord::Base
	belongs_to :professional
	belongs_to :certificate
end
