class Attachment::IntegratedBasesDocument < ActiveRecord::Base
  belongs_to :work
  has_attached_file :testimony_of_consortium
  validates_attachment_content_type :testimony_of_consortium, :content_type => ['application/pdf', 'application/msword', 'text/plain']
end
