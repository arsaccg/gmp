class Flowchart < ActiveRecord::Base
  has_attached_file :photo
  validates_attachment_content_type :photo, :content_type => [ 'application/pdf'],  :in => 0.megabytes..40.megabytes
end
