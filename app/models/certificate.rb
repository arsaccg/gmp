class Certificate < ActiveRecord::Base
	has_one :charge
	has_and_belongs_to_many :professionals

	has_attached_file :certificate
    validates_attachment_content_type :certificate, :content_type =>['application/pdf', 'application/msword', 'text/plain']
end
