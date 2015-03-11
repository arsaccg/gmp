class ValorizationDoc < ActiveRecord::Base
  belongs_to :type_of_valorization_doc
  has_attached_file :document
  validates_attachment_content_type :document, :content_type => ['application/pdf', 'application/msword', 'application/vnd.ms-excel', 'application/msexcel', 'application/excel', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],  :in => 0.megabytes..40.megabytes
end
