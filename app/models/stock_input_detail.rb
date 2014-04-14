class StockInputDetail < ActiveRecord::Base
  belongs_to :stock_input
  belongs_to :purchase_order_detail

  default_scope { where(status: "A").order("id ASC") }
  after_validation :do_activecreate, on: [:create]
  
  def do_activecreate
    self.status = "A"
  end
  
end
