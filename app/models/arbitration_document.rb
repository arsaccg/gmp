class ArbitrationDocument < ActiveRecord::Base
	belongs_to :work
	has_attached_file :attachment
    validates_attachment_content_type :attachment, :content_type => ['application/pdf', 'application/msword', 'text/plain']
end
