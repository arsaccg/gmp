class FormatPerDocument < ActiveRecord::Base
  belongs_to :document
  belongs_to :format
  after_validation :do_activecreate, on: [:create]

  default_scope { where(status: "A").order("id ASC") }
  
  def do_activecreate
    self.status = "A"
  end

end
