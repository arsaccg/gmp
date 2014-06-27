class LawAndRegulation < ActiveRecord::Base
	has_and_belongs_to_many :type_of_law_and_regulations

	has_attached_file :document
  validates_attachment_content_type :document, :content_type => ['application/pdf', 'application/msword', 'text/plain']
end
