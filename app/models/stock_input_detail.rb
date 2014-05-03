class StockInputDetail < ActiveRecord::Base
  belongs_to :stock_input
  belongs_to :purchase_order_detail
  belongs_to :article
  
  default_scope { where(status: "A") }#.order("id ASC")
  after_validation :do_activecreate, on: [:create]
  
  def do_activecreate
    self.status = "A"
  end

  def self.get_kardex_detail(user, date_type, from_date, to_date)
    case date_type
      when "1" # Periodo / Calendar
        joins{stock_input.warehouse}
        .joins{purchase_order_detail.outer.delivery_order_detail.outer.article.outer.unit_of_measurement.outer}
        .joins{article.outer.unit_of_measurement.outer}
        .joins{article.outer.rep_inv_article.outer}
        .joins{purchase_order_detail.outer.delivery_order_detail.outer.rep_inv_article.outer}
        .joins{stock_input.rep_inv_warehouse}
        .joins{stock_input.rep_inv_supplier}
        .joins{stock_input.rep_inv_period}
        .joins{stock_input.rep_inv_format}
        .joins{purchase_order_detail.outer.purchase_order.outer.rep_inv_money.outer}
        .where{(rep_inv_warehouses.user.eq "#{user}") &
               (rep_inv_suppliers.user.eq "#{user}") &
               (rep_inv_periods.user.eq "#{user}") &
               (rep_inv_formats.user.eq "#{user}") &
               (
                (rep_inv_articles.user.eq "#{user}") |
                (rep_inv_articles_delivery_order_details.user.eq "#{user}")
               ) &
               (stock_inputs.issue_date.gteq "#{from_date}") &
               (stock_inputs.issue_date.lteq "#{to_date}")}
        .select{stock_inputs.input}
        .select{stock_inputs.warehouse_id}
        .select{warehouses.name.as(warehouse_name)}
        .select{stock_inputs.period}
        .select{stock_inputs.issue_date}
        .select{coalesce(article_id, delivery_order_details.article_id).as(article_id)}
        .select{coalesce(articles_stock_input_details.code,articles.code).as(article_code)}
        .select{coalesce(articles_stock_input_details.name,articles.name).as(article_name)}
        .select{('coalesce(unit_of_measurements_articles.symbol,unit_of_measurements.symbol) AS article_symbol')}
        .select('stock_input_details.amount')
        .reorder('period, issue_date, article_name')
      when "2" # TimeLine by Cost Center
        joins{stock_input.warehouse}
        .joins{stock_input.link_period}
        .joins{purchase_order_detail.outer.delivery_order_detail.outer.article.outer.unit_of_measurement.outer}
        .joins{article.outer.unit_of_measurement.outer}
        .joins{article.outer.rep_inv_article.outer}
        .joins{purchase_order_detail.outer.delivery_order_detail.outer.rep_inv_article.outer}
        .joins{stock_input.rep_inv_warehouse}
        .joins{stock_input.rep_inv_supplier}
        .joins{stock_input.rep_inv_period}
        .joins{stock_input.rep_inv_format}
        .joins{purchase_order_detail.outer.purchase_order.outer.rep_inv_money.outer}
        .where{(link_periods.cost_center_id.eq warehouses.cost_center_id) &
               (rep_inv_warehouses.user.eq "#{user}") &
               (rep_inv_suppliers.user.eq "#{user}") &
               (rep_inv_periods.user.eq "#{user}") &
               (rep_inv_formats.user.eq "#{user}") &
               (
                (rep_inv_articles.user.eq "#{user}") |
                (rep_inv_articles_delivery_order_details.user.eq "#{user}")
               ) &
               (stock_inputs.issue_date.gteq "#{from_date}") &
               (stock_inputs.issue_date.lteq "#{to_date}")}
        .select{stock_inputs.input}
        .select{stock_inputs.warehouse_id}
        .select{warehouses.name.as(warehouse_name)}
        .select{link_periods.month.as(period)}
        .select{stock_inputs.issue_date}
        .select{coalesce(article_id, delivery_order_details.article_id).as(article_id)}
        .select{coalesce(articles_stock_input_details.code,articles.code).as(article_code)}
        .select{coalesce(articles_stock_input_details.name,articles.name).as(article_name)}
        .select{('coalesce(unit_of_measurements_articles.symbol,unit_of_measurements.symbol) AS article_symbol')}
        .select('stock_input_details.amount')
        .reorder('period, issue_date, article_name')
    end
  end

  def self.get_kardex_monthly(user, date_type, from_date, to_date)
    case date_type
      when "1" # Periodo / Calendar
        joins{stock_input.warehouse}
        .joins{purchase_order_detail.outer.delivery_order_detail.outer.article.outer.unit_of_measurement.outer}
        .joins{article.outer.unit_of_measurement.outer}
        .joins{article.outer.rep_inv_article.outer}
        .joins{purchase_order_detail.outer.delivery_order_detail.outer.rep_inv_article.outer}
        .joins{stock_input.rep_inv_warehouse}
        .joins{stock_input.rep_inv_supplier}
        .joins{stock_input.rep_inv_period}
        .joins{stock_input.rep_inv_format}
        .joins{purchase_order_detail.outer.purchase_order.outer.rep_inv_money.outer}
        .where{(rep_inv_warehouses.user.eq "#{user}") &
               (rep_inv_suppliers.user.eq "#{user}") &
               (rep_inv_periods.user.eq "#{user}") &
               (rep_inv_formats.user.eq "#{user}") &
               (
                (rep_inv_articles.user.eq "#{user}") |
                (rep_inv_articles_delivery_order_details.user.eq "#{user}")
               ) &
               (stock_inputs.issue_date.gteq "#{from_date}") &
               (stock_inputs.issue_date.lteq "#{to_date}")}
        .group{stock_inputs.input}
        .group{stock_inputs.warehouse_id}
        .group{warehouses.name}
        .group{stock_inputs.period}
        .group{article_id}
        .group{'articles_stock_input_details.code'}
        .group{'articles_stock_input_details.name'}
        .group{'unit_of_measurements_articles.symbol'}
        .group{delivery_order_details.article_id}
        .group{articles.code}
        .group{articles.name}
        .group{'unit_of_measurements.symbol'}
        .select{stock_inputs.input}
        .select{stock_inputs.warehouse_id}
        .select{warehouses.name}
        .select{stock_inputs.period}
        .select{article_id}
        .select{'articles_stock_input_details.code'}
        .select{'articles_stock_input_details.name'}
        .select{'unit_of_measurements_articles.symbol'}
        .select{delivery_order_details.article_id}
        .select{articles.code}
        .select{articles.name}
        .select{'unit_of_measurements.symbol'}
        .sum('stock_input_details.amount')
      when "2" # TimeLine by Cost Center
        joins{stock_input.warehouse}
        .joins{stock_input.link_period}
        .joins{purchase_order_detail.outer.delivery_order_detail.outer.article.outer.unit_of_measurement.outer}
        .joins{article.outer.unit_of_measurement.outer}
        .joins{article.outer.rep_inv_article.outer}
        .joins{purchase_order_detail.outer.delivery_order_detail.outer.rep_inv_article.outer}
        .joins{stock_input.rep_inv_warehouse}
        .joins{stock_input.rep_inv_supplier}
        .joins{stock_input.rep_inv_period}
        .joins{stock_input.rep_inv_format}
        .joins{purchase_order_detail.outer.purchase_order.outer.rep_inv_money.outer}
        .where{(link_periods.cost_center_id.eq warehouses.cost_center_id) &
               (rep_inv_warehouses.user.eq "#{user}") &
               (rep_inv_suppliers.user.eq "#{user}") &
               (rep_inv_periods.user.eq "#{user}") &
               (rep_inv_formats.user.eq "#{user}") &
               (
                (rep_inv_articles.user.eq "#{user}") |
                (rep_inv_articles_delivery_order_details.user.eq "#{user}")
               ) &
               (stock_inputs.issue_date.gteq "#{from_date}") &
               (stock_inputs.issue_date.lteq "#{to_date}")}
        .group{stock_inputs.input}
        .group{stock_inputs.warehouse_id}
        .group{warehouses.name}
        .group{link_periods.month}
        .group{article_id}
        .group{'articles_stock_input_details.code'}
        .group{'articles_stock_input_details.name'}
        .group{'unit_of_measurements_articles.symbol'}
        .group{delivery_order_details.article_id}
        .group{articles.code}
        .group{articles.name}
        .group{'unit_of_measurements.symbol'}
        .select{stock_inputs.input}
        .select{stock_inputs.warehouse_id}
        .select{warehouses.name}
        .select{link_periods.month.as(period)}
        .select{article_id}
        .select{'articles_stock_input_details.code'}
        .select{'articles_stock_input_details.name'}
        .select{'unit_of_measurements_articles.symbol'}
        .select{delivery_order_details.article_id}
        .select{articles.code}
        .select{articles.name}
        .select{'unit_of_measurements.symbol'}
        .sum('stock_input_details.amount')
    end
  end

  def self.get_kardex_yearly(user, date_type, from_date, to_date)
    case date_type
      when "1" # Periodo / Calendar
        joins{stock_input.warehouse}
        .joins{purchase_order_detail.outer.delivery_order_detail.outer.article.outer.unit_of_measurement.outer}
        .joins{article.outer.unit_of_measurement.outer}
        .joins{article.outer.rep_inv_article.outer}
        .joins{purchase_order_detail.outer.delivery_order_detail.outer.rep_inv_article.outer}
        .joins{stock_input.rep_inv_warehouse}
        .joins{stock_input.rep_inv_supplier}
        .joins{stock_input.rep_inv_period}
        .joins{stock_input.rep_inv_format}
        .joins{purchase_order_detail.outer.purchase_order.outer.rep_inv_money.outer}
        .where{(rep_inv_warehouses.user.eq "#{user}") &
               (rep_inv_suppliers.user.eq "#{user}") &
               (rep_inv_periods.user.eq "#{user}") &
               (rep_inv_formats.user.eq "#{user}") &
               (
                (rep_inv_articles.user.eq "#{user}") |
                (rep_inv_articles_delivery_order_details.user.eq "#{user}")
               ) &
               (stock_inputs.issue_date.gteq "#{from_date}") &
               (stock_inputs.issue_date.lteq "#{to_date}")}
        .group{stock_inputs.input}
        .group{stock_inputs.warehouse_id}
        .group{warehouses.name}
        .group{left(stock_inputs.period,4)}
        .group{article_id}
        .group{'articles_stock_input_details.code'}
        .group{'articles_stock_input_details.name'}
        .group{'unit_of_measurements_articles.symbol'}
        .group{delivery_order_details.article_id}
        .group{articles.code}
        .group{articles.name}
        .group{'unit_of_measurements.symbol'}
        .select{stock_inputs.input}
        .select{stock_inputs.warehouse_id}
        .select{warehouses.name}
        .select{left(stock_inputs.period,4).as(anho)}
        .select{article_id}
        .select{'articles_stock_input_details.code'}
        .select{'articles_stock_input_details.name'}
        .select{'unit_of_measurements_articles.symbol'}
        .select{delivery_order_details.article_id}
        .select{articles.code}
        .select{articles.name}
        .select{'unit_of_measurements.symbol'}
        .sum('stock_input_details.amount')
      when "2" # TimeLine by Cost Center
        joins{stock_input.warehouse}
        .joins{stock_input.link_period}
        .joins{purchase_order_detail.outer.delivery_order_detail.outer.article.outer.unit_of_measurement.outer}
        .joins{article.outer.unit_of_measurement.outer}
        .joins{article.outer.rep_inv_article.outer}
        .joins{purchase_order_detail.outer.delivery_order_detail.outer.rep_inv_article.outer}
        .joins{stock_input.rep_inv_warehouse}
        .joins{stock_input.rep_inv_supplier}
        .joins{stock_input.rep_inv_period}
        .joins{stock_input.rep_inv_format}
        .joins{purchase_order_detail.outer.purchase_order.outer.rep_inv_money.outer}
        .where{(link_periods.cost_center_id.eq warehouses.cost_center_id) &
               (rep_inv_warehouses.user.eq "#{user}") &
               (rep_inv_suppliers.user.eq "#{user}") &
               (rep_inv_periods.user.eq "#{user}") &
               (rep_inv_formats.user.eq "#{user}") &
               (
                (rep_inv_articles.user.eq "#{user}") |
                (rep_inv_articles_delivery_order_details.user.eq "#{user}")
               ) &
               (stock_inputs.issue_date.gteq "#{from_date}") &
               (stock_inputs.issue_date.lteq "#{to_date}")}
        .group{stock_inputs.input}
        .group{stock_inputs.warehouse_id}
        .group{warehouses.name}
        .group{left(link_periods.month,4)}
        .group{article_id}
        .group{'articles_stock_input_details.code'}
        .group{'articles_stock_input_details.name'}
        .group{'unit_of_measurements_articles.symbol'}
        .group{delivery_order_details.article_id}
        .group{articles.code}
        .group{articles.name}
        .group{'unit_of_measurements.symbol'}
        .select{stock_inputs.input}
        .select{stock_inputs.warehouse_id}
        .select{warehouses.name}
        .select{left(link_periods.month,4).as(anho)}
        .select{article_id}
        .select{'articles_stock_input_details.code'}
        .select{'articles_stock_input_details.name'}
        .select{'unit_of_measurements_articles.symbol'}
        .select{delivery_order_details.article_id}
        .select{articles.code}
        .select{articles.name}
        .select{'unit_of_measurements.symbol'}
        .sum('stock_input_details.amount')
    end
  end
  
end
