class Professional < ActiveRecord::Base
	has_and_belongs_to_many :majors
	has_and_belongs_to_many :certificates

	has_attached_file :professional_title
    validates_attachment_content_type :professional_title, :content_type => ['application/pdf', 'application/msword', 'text/plain']

    has_attached_file :tuition
    validates_attachment_content_type :tuition, :content_type => ['application/pdf', 'application/msword', 'text/plain']
    
    has_attached_file :cv
    validates_attachment_content_type :cv, :content_type => ['application/pdf', 'application/msword', 'text/plain']
end