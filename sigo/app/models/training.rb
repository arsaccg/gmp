class Training < ActiveRecord::Base
	belongs_to :professional

	has_attached_file :training
    validates_attachment_content_type :training, :content_type => ['application/pdf', 'application/msword', 'text/plain', 'application/msexcel', /\Aimage\/.*\Z/]
end
