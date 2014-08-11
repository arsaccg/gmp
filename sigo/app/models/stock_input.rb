class StockInput < ActiveRecord::Base
  has_many :stock_input_details
  belongs_to :supplier, :foreign_key => 'supplier_id'
  belongs_to :responsible, :foreign_key => 'responsible_id'
  belongs_to :warehouse
  belongs_to :format
  belongs_to :working_group
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

  def self.get_articles_in_stock
    stock_net_array = Array.new
    squal_inputs = "SELECT a.id, a.code, a.name, uom.name, SUM( sid.amount ) FROM stock_inputs si, stock_input_details sid, articles a, unit_of_measurements uom WHERE si.input = 1 AND sid.stock_input_id = si.id AND sid.article_id = a.id AND a.unit_of_measurement_id = uom.id GROUP BY sid.article_id"
    squal_outputs = "SELECT a.id, a.code, SUM( sid.amount ) FROM stock_inputs si, stock_input_details sid, articles a WHERE si.input = 0 AND sid.stock_input_id = si.id AND sid.article_id = a.id GROUP BY sid.article_id"
    ActiveRecord::Base.connection.execute(squal_inputs).each do |input|
      ActiveRecord::Base.connection.execute(squal_outputs).each do |output|
        if input[1] == output[1]
          if input[4] > output[2]
            net = input[4] - output[2]
            stock_net_array << { 'id' => input[0].to_s + '-' + net.to_i.to_s, 'code' => input[1], 'name' => input[2], 'symbol' => input[3], 'stock' => net }
          end
        else
          stock_net_array << { 'id' => input[0].to_s + '-' + input[4].to_i.to_s, 'code' => input[1], 'name' => input[2], 'symbol' => input[3], 'stock' => input[4] }
        end
      end
    end

    return stock_net_array 

  end

end
