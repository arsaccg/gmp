class StockInput < ActiveRecord::Base
  has_many :stock_input_details
  belongs_to :entity, :foreign_key => 'supplier_id'
  belongs_to :warehouse
  belongs_to :format
  #belongs_to :rep_inv_cost_center, :foreign_key => 'warehouse_id'
  belongs_to :rep_inv_warehouse, :foreign_key => 'warehouse_id'
  belongs_to :rep_inv_supplier, :foreign_key => 'supplier_id'
  belongs_to :rep_inv_year, :foreign_key => 'year'
  belongs_to :rep_inv_period, :foreign_key => 'period'
  belongs_to :rep_inv_format, :foreign_key => 'format_id'
  belongs_to :rep_inv_money, :foreign_key => 'money_id'
  belongs_to :link_period, :foreign_key => 'issue_date'

  accepts_nested_attributes_for :stock_input_details, :allow_destroy => true

  default_scope { where(status: "A").order("period, issue_date ASC") }
  after_validation :do_activecreate, on: [:create]
  
  def do_activecreate
    self.status = "A"
  end

end
