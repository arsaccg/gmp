class Work < ActiveRecord::Base
  has_and_belongs_to_many :components
  has_and_belongs_to_many :work_partners
  belongs_to :entity
  belongs_to :money

  # Extra Documents
  has_many :arbitration_documents
  has_many :contract_documents
  has_many :integrated_bases_documents
  has_many :testimony_of_consortium_documents

  accepts_nested_attributes_for :arbitration_documents, :allow_destroy => true
  accepts_nested_attributes_for :contract_documents, :allow_destroy => true
  accepts_nested_attributes_for :integrated_bases_documents, :allow_destroy => true
  accepts_nested_attributes_for :testimony_of_consortium_documents, :allow_destroy => true

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

  has_attached_file :compliance_work
  validates_attachment_content_type :compliance_work, :content_type => ['application/pdf', 'application/msword', 'text/plain']

  def self.getContractorName(id_contractor)
    return Entity.find(id_contractor).name
  end
end
