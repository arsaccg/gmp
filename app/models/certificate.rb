class Certificate < ActiveRecord::Base
	has_one :charge
	belongs_to :professional

	has_attached_file :certificate
    validates_attachment_content_type :certificate, :content_type =>['application/pdf', 'application/msword', 'text/plain']

    has_attached_file :other
    validates_attachment_content_type :other, :content_type =>['application/pdf', 'application/msword', 'text/plain']
end