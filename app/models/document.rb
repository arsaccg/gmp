class Document < ActiveRecord::Base
  has_many :format_per_documents
  has_many :format, :through => :format_per_documents
  accepts_nested_attributes_for :format_per_documents, :allow_destroy => true

  default_scope { where(status: "A").order("name ASC") }
  after_validation :do_activecreate, on: [:create]
  
  def do_activecreate
    self.status = "A"
  end

  def do_inactive
    self.status = "D"
  end

  # Validaciones
  include ActiveModel::Validations
  validates :name, :uniqueness => { :scope => :status, :case_sensitive => false }

end
