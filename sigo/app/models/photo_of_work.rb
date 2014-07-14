class PhotoOfWork < ActiveRecord::Base
	self.per_page = 21
	has_attached_file :photo
  validates_attachment_content_type :photo, :content_type => [ /\Aimage\/.*\Z/]
end
