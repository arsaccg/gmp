class Warehouse < ActiveRecord::Base
  belongs_to :cost_center
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
  validates :name, :uniqueness => { :case_sensitive => false }
	
end
