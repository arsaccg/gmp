class StockInput < ActiveRecord::Base
  has_many :stock_input_details
  belongs_to :entity, :foreign_key => 'supplier_id'
  belongs_to :warehouse
  belongs_to :format

  accepts_nested_attributes_for :stock_input_details, :allow_destroy => true

  default_scope { where(status: "A").order("issue_date ASC") }
  after_validation :do_activecreate, on: [:create]
  
  def do_activecreate
    self.status = "A"
  end

end
