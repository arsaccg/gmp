class Training < ActiveRecord::Base
	has_many :professional_training
	has_many :professionals, :through => :professional_training

	has_attached_file :training
    validates_attachment_content_type :training, :content_type =>['application/pdf', 'application/msword', 'text/plain']
end
