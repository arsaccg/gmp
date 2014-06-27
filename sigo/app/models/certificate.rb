class Certificate < ActiveRecord::Base
	has_one :charge
	has_one :other_work
	belongs_to :professional

	has_attached_file :certificate
  validates_attachment_content_type :certificate, :content_type => ['application/pdf', 'application/msword', 'text/plain', 'application/msexcel', /\Aimage\/.*\Z/, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']

  has_attached_file :other
  validates_attachment_content_type :other, :content_type => ['application/pdf', 'application/msword', 'text/plain', 'application/msexcel', /\Aimage\/.*\Z/, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']
end
