class BondLetterDetail < ActiveRecord::Base
  belongs_to :bond_letter
  has_attached_file :document
  validates_attachment_content_type :document, :content_type => ['application/pdf',  /\Aimage\/.*\Z/],  :in => 0.megabytes..40.megabytes  
end
