class WorkerContract < ActiveRecord::Base
  belongs_to :worker, :touch => true
  belongs_to :article
  belongs_to :contract_type
  has_many :worker_contract_details

  accepts_nested_attributes_for :worker_contract_details, :allow_destroy => true

  has_attached_file :document, :default_url => lambda { |image| ActionController::Base.helpers.asset_path('NotAvailable300.png') }
  validates_attachment_content_type :document, :content_type => [ 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',/\Aimage\/.*\Z/]

end
