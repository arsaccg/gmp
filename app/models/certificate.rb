class Certificate < ActiveRecord::Base
	has_many :professional_certificate
	has_many :professionals, :through => :professional_certificate

	has_attached_file :certificate
    validates_attachment_content_type :certificate, :content_type =>['application/pdf']
end
