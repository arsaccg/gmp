class TechnicalStandard < ActiveRecord::Base
	has_attached_file :document
	validates_attachment_content_type :document, :content_type => ['application/pdf', 'application/msword', 'text/plain']
end
