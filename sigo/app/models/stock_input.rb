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

  def self.get_articles_in_stock(word)
    stock_net_array = Array.new
    squal_inputs = ActiveRecord::Base.connection.execute("SELECT a.id, a.code, a.name, uom.name, SUM( sid.amount ) FROM stock_inputs si, stock_input_details sid, articles a, unit_of_measurements uom WHERE si.input = 1 AND si.status = 'A' AND sid.stock_input_id = si.id AND sid.article_id = a.id AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' ) AND a.unit_of_measurement_id = uom.id GROUP BY sid.article_id")
    squal_outputs = ActiveRecord::Base.connection.execute("SELECT a.id, a.code, SUM( sid.amount ) FROM stock_inputs si, stock_input_details sid, articles a WHERE si.input = 0 AND sid.stock_input_id = si.id AND si.status = 'A' AND sid.article_id = a.id GROUP BY sid.article_id")

    squal_inputs.each do |input|
      puts "-----------------------------"
      puts input.inspect
      puts "-----------------------------"
      squal_outputs.each do |output|
        puts "-----------------------------"
        puts output.inspect
        puts "-----------------------------" 
        puts "-----------------------------"
        puts input[0]
        puts output[0]
        puts "-----------------------------"               
        if input[0] == output[0]
          puts "-----------------------------"
          puts input[4]
          puts output[2]
          puts "-----------------------------"            
          if input[4] > output[2]
            net = input[4] - output[2]
            stock_net_array << { 'id' => input[0].to_s + '-' + net.to_i.to_s, 'code' => input[1], 'name' => input[2], 'symbol' => input[3], 'stock' => net }
          end
        end
      end
      if squal_outputs.count==0
        stock_net_array << { 'id' => input[0].to_s + '-' + input[4].to_i.to_s, 'code' => input[1], 'name' => input[2], 'symbol' => input[3], 'stock' => input[4] }
      end
    end

    return stock_net_array 

  end



  def self.get_stock(article)
    net=""
    squal_inputs = "SELECT a.id, a.code, a.name, uom.name, SUM( sid.amount ) FROM stock_inputs si, stock_input_details sid, articles a, unit_of_measurements uom WHERE si.input = 1 AND sid.stock_input_id = si.id AND sid.article_id = a.id AND a.unit_of_measurement_id = uom.id AND a.id =#{article} GROUP BY sid.article_id"
    squal_outputs = "SELECT a.id, a.code, SUM( sid.amount ) FROM stock_inputs si, stock_input_details sid, articles a WHERE si.input = 0 AND sid.stock_input_id = si.id AND sid.article_id = a.id AND a.id =#{article} GROUP BY sid.article_id"
              puts "--------entra a---------"
      ActiveRecord::Base.connection.execute(squal_inputs).each do |input|
              puts "--------entra b---------"  
              net = input[4]     
        ActiveRecord::Base.connection.execute(squal_outputs).each do |output|
              puts "--------entra---------"
            if input[4] > output[2]
              puts "-------if----------"
              puts input[4]
              puts output[2]
              puts "-----valores------------"
              net = net - output[2]
            end
        end
      end


    return net

  end

  def self.getSupplier(word, cc)
    ent = ActiveRecord::Base.connection.execute("
      SELECT ent.id, CONCAT( ent.ruc,  ' - ', ent.name )
      FROM purchase_orders po, entities ent
      WHERE po.state =  'approved'
      AND po.entity_id = ent.id
      AND (ent.name LIKE  '%"+word.to_s+"%' OR ent.ruc LIKE  '%"+word.to_s+"%')
      AND po.cost_center_id = "+cc.to_s+"
      GROUP BY ent.id")
    return ent
  end




#----------
end
