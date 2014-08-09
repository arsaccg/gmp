class BookWork < ActiveRecord::Base
  belongs_to :type_of_book_work
  has_attached_file :document
  validates_attachment_content_type :document, :content_type => ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'],  :in => 0.megabytes..40.megabytes
end
