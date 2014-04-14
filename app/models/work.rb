class Work < ActiveRecord::Base
  has_and_belongs_to_many :components
  belongs_to :entity

  has_attached_file :testimony_of_consortium
  validates_attachment_content_type :testimony_of_consortium, :content_type => ['application/pdf', 'application/msword', 'text/plain']

  has_attached_file :contract
  validates_attachment_content_type :contract, :content_type => ['application/pdf', 'application/msword', 'text/plain']

  has_attached_file :reception_certificate
  validates_attachment_content_type :reception_certificate, :content_type => ['application/pdf', 'application/msword', 'text/plain']

  has_attached_file :settlement_of_work
  validates_attachment_content_type :settlement_of_work, :content_type => ['application/pdf', 'application/msword', 'text/plain']

  has_attached_file :budget
  validates_attachment_content_type :budget, :content_type => ['application/pdf', 'application/msword', 'text/plain']

  has_attached_file :integrated_bases
  validates_attachment_content_type :integrated_bases, :content_type => ['application/pdf', 'application/msword', 'text/plain']

  has_attached_file :arbitration
  validates_attachment_content_type :arbitration, :content_type => ['application/pdf', 'application/msword', 'text/plain']
end
