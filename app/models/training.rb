class Training < ActiveRecord::Base
	has_and_belongs_to_many :professionals

	has_attached_file :training
    validates_attachment_content_type :training, :content_type =>['application/pdf', 'application/msword', 'text/plain']
end
