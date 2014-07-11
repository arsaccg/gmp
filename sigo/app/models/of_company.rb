class OfCompany < ActiveRecord::Base
	has_and_belongs_to_many :type_of_companies
	has_attached_file :document
  validates_attachment_content_type :document, :content_type => ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
end
