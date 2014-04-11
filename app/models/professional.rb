class Professional < ActiveRecord::Base
	has_many :professional_certificate
	has_many :certificates, :through => :professional_certificate

	has_many :professional_training
	has_many :trainings, :through => :professional_training

	has_attached_file :professional_title
    validates_attachment_content_type :professional_title, :content_type =>['application/pdf']

    has_attached_file :tuition
    validates_attachment_content_type :tuition, :content_type =>['application/pdf']
end