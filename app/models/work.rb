class Work < ActiveRecord::Base
<<<<<<< HEAD
	has_many :components
=======
  has_many :components
  belongs_to :entity

  has_attached_file :testimony_of_consortium
  validates_attachment_content_type :testimony_of_consortium, :content_type => ['application/pdf', 'application/msword', 'text/plain']

  has_attached_file :contract
  validates_attachment_content_type :contract, :content_type => /\Aimage\/.*\Z/

  has_attached_file :reception_certificate
  validates_attachment_content_type :reception_certificate, :content_type => ['application/pdf', 'application/msword', 'text/plain']

  has_attached_file :settlement_of_work
  validates_attachment_content_type :settlement_of_work, :content_type => ['application/pdf', 'application/msword', 'text/plain']
>>>>>>> d6e726393a19f38edfd36f503b480234ad4e9f4c
end
