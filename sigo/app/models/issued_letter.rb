class IssuedLetter < ActiveRecord::Base
	belongs_to :type_of_issued_letter
	has_attached_file :document
  validates_attachment_content_type :document, :content_type => ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
end
