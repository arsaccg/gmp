class StockInputDetail < ActiveRecord::Base
  belongs_to :stock_input, :touch => true
  belongs_to :purchase_order_detail
  belongs_to :article
  belongs_to :phase
  belongs_to :sector
  default_scope { where(status: "A") }#.order("id ASC")
  after_validation :do_activecreate, on: [:create]
  
  def do_activecreate
    self.status = "A"
  end

  def self.get_kardex_summary(updatefilter, company_id, cost_center_id, user, report_type, date_type, from_date, to_date, warehouses, suppliers, responsibles, years, periods, formats, articles, moneys)
    case date_type
      when "1" # Periodo / Calendar
        ActiveRecord::Base.connection.execute("CALL REP_INV_KARDEX_CALENDAR(#{updatefilter}, #{company_id}, #{cost_center_id}, #{report_type}, 4, #{user}, '#{from_date}', '#{to_date}', '#{warehouses}', '#{suppliers}', '#{responsibles}', '#{years}', '#{periods}', '#{formats}', '#{articles}', '#{moneys}');")
      when "2" # TimeLine by Cost Center
        ActiveRecord::Base.connection.execute("CALL REP_INV_KARDEX_COST_CENTER(#{updatefilter}, #{company_id}, #{cost_center_id}, #{report_type}, 4, #{user}, '#{from_date}', '#{to_date}', '#{warehouses}', '#{suppliers}', '#{responsibles}', '#{years}', '#{periods}', '#{formats}', '#{articles}', '#{moneys}');")
    end
  end

  def self.get_kardex_daily(updatefilter, company_id, cost_center_id, user, report_type, date_type, from_date, to_date, warehouses, suppliers, responsibles, years, periods, formats, articles, moneys)
    case date_type
      when "1" # Periodo / Calendar
        ActiveRecord::Base.connection.execute("CALL REP_INV_KARDEX_CALENDAR(#{updatefilter}, #{company_id}, #{cost_center_id}, #{report_type}, 3, #{user}, '#{from_date}', '#{to_date}', '#{warehouses}', '#{suppliers}', '#{responsibles}', '#{years}', '#{periods}', '#{formats}', '#{articles}', '#{moneys}');")
      when "2" # TimeLine by Cost Center
        ActiveRecord::Base.connection.execute("CALL REP_INV_KARDEX_COST_CENTER(#{updatefilter}, #{company_id}, #{cost_center_id}, #{report_type}, 3, #{user}, '#{from_date}', '#{to_date}', '#{warehouses}', '#{suppliers}', '#{responsibles}', '#{years}', '#{periods}', '#{formats}', '#{articles}', '#{moneys}');")
    end
  end

  def self.get_kardex_monthly(updatefilter, company_id, cost_center_id, user, report_type, date_type, from_date, to_date, warehouses, suppliers, responsibles, years, periods, formats, articles, moneys)
    case date_type
      when "1" # Periodo / Calendar
        ActiveRecord::Base.connection.execute("CALL REP_INV_KARDEX_CALENDAR(#{updatefilter}, #{company_id}, #{cost_center_id}, #{report_type}, 2, #{user}, '#{from_date}', '#{to_date}', '#{warehouses}', '#{suppliers}', '#{responsibles}', '#{years}', '#{periods}', '#{formats}', '#{articles}', '#{moneys}');")
      when "2" # TimeLine by Cost Center
        ActiveRecord::Base.connection.execute("CALL REP_INV_KARDEX_COST_CENTER(#{updatefilter}, #{company_id}, #{cost_center_id}, #{report_type}, 2, #{user}, '#{from_date}', '#{to_date}', '#{warehouses}', '#{suppliers}', '#{responsibles}', '#{years}', '#{periods}', '#{formats}', '#{articles}', '#{moneys}');")
    end
  end

  def self.get_kardex_yearly(updatefilter, company_id, cost_center_id, user, report_type, date_type, from_date, to_date, warehouses, suppliers, responsibles, years, periods, formats, articles, moneys)
    case date_type
      when "1" # Periodo / Calendar
        ActiveRecord::Base.connection.execute("CALL REP_INV_KARDEX_CALENDAR(#{updatefilter}, #{company_id}, #{cost_center_id}, #{report_type}, 1, #{user}, '#{from_date}', '#{to_date}', '#{warehouses}', '#{suppliers}', '#{responsibles}', '#{years}', '#{periods}', '#{formats}', '#{articles}', '#{moneys}');")
      when "2" # TimeLine by Cost Center
        ActiveRecord::Base.connection.execute("CALL REP_INV_KARDEX_COST_CENTER(#{updatefilter}, #{company_id}, #{cost_center_id}, #{report_type}, 1, #{user}, '#{from_date}', '#{to_date}', '#{warehouses}', '#{suppliers}', '#{responsibles}', '#{years}', '#{periods}', '#{formats}', '#{articles}', '#{moneys}');")
    end
  end
  
end
