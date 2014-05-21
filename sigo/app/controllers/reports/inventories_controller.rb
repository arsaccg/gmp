class Reports::InventoriesController < ApplicationController
  def index
    if params[:company_id] != nil
      @company = params[:company_id]
      # Cache -> company_id
      cache = ActiveSupport::Cache::MemoryStore.new(expires_in: 120.minutes)
      Rails.cache.write('company_id', @company)
    else
      @company = Rails.cache.read('company_id')
    end
    @cost_centers = CostCenter.where("company_id = " + @company)
    @warehouses = Warehouse.where("company_id = " + @company)
    @suppliers = Entity.joins(:type_entities).where("type_entities.preffix" => "P")
    @responsibles = Entity.joins(:type_entities).where("type_entities.preffix" => "T")
    @years = Array.new
    (2000..2050).each do |x|
      @years << x
    end
    @periods = LinkTime.group(:year, :month).uniq
    @formats = Format.all
    @articles = Article.joins(:type_of_article).where("type_of_articles.code" => "02")
    @moneys = Money.all
    render layout: false
  end

  def show

  end

  def show_rows_results
    @user = current_user.id

    #-------------------------------
    # CostCenter
    #-------------------------------
    @cost_centers = ""
    if params[:cost_center_id] != ""
      @cost_centers = ","
      params[:cost_center_id].each.with_index(1) do |x, i|
        @cost_centers += x.to_s + ","
      end
    end
    #-------------------------------
    # Warehouses
    #-------------------------------
    @warehouses = ""
    if params[:warehouse_id] != ""
      @warehouses = ","
      params[:warehouse_id].each.with_index(1) do |x, i|
        @warehouses += x.to_s + ","
      end
    end
    #-------------------------------
    # Supplier
    #-------------------------------
    @suppliers = ""
    if params[:supplier_id] != ""
      @suppliers = ","
      params[:supplier_id].each.with_index(1) do |x, i|
        @suppliers += x.to_s + ","
      end
    end
    #-------------------------------
    # Year
    #-------------------------------
    @years = ""
    if params[:year_id] != ""
      @years = ","
      params[:year_id].each.with_index(1) do |x, i|
        @years += x.to_s + ","
      end
    end
    #-------------------------------
    # Period
    #-------------------------------
    @periods = ""
    if params[:period_id] != ""
      @periods = ","
      params[:period_id].each.with_index(1) do |x, i|
        @periods += x.to_s + ","
      end
    end
    #-------------------------------
    # Format
    #-------------------------------
    @formats = ""
    if params[:format_id] != ""
      @formats = ","
      params[:format_id].each.with_index(1) do |x, i|
        @formats += x.to_s + ","
      end
    end
    #-------------------------------
    # Articles
    #-------------------------------
    @articles = ""
    if params[:article_id] != ""
      @articles = ","
      params[:article_id].each.with_index(1) do |x, i|
        @articles += x.to_s + ","
      end
    end
    #  Article.joins(:type_of_article).where("type_of_articles.code" => "02").all.each do |x|
    #-------------------------------
    # Money
    #-------------------------------
    @moneys = ""
    if params[:money_id] != ""
      @moneys = ","
      params[:money_id].each.with_index(1) do |x, i|
        @moneys += x.to_s + ","
      end
    end
    #-------------------------------
    #logger.info "PARAMETROS---:"

    if params[:since_date] != ""
      @since_date = Date.strptime(params[:since_date], '%d/%m/%Y')
    else
      @since_date = Date.strptime("01/01/1900", '%d/%m/%Y')
    end if
    
    if params[:to_date] != ""
      @to_date = Date.strptime(params[:to_date], '%d/%m/%Y')
    else
      @to_date = Date.strptime("31/12/2050", '%d/%m/%Y')
    end if
    @series = params[:series]
    @document = params[:document]

    @date_type = params[:date_type]
    @report_type = params[:report_type]
 
    #if params[:report_type] == "1" # Stock Input
    #  @reportRows = StockInputDetail.get_inputs(@user, @since_date, @to_date, @series, @document)
    #  render(partial: 'show_rows_stock_input', :layout => false)
    #elsif params[:report_type] == "2" # Stock Output
    #  @reportRows = StockInputDetail.get_outputs(@user, @since_date, @to_date, @document)
    #  render(partial: 'show_rows_stock_output', :layout => false)
    #elsif params[:report_type] == "3" # Kardex
    case params[:report_action]
      when "1" # Find
        case params[:kardex_type]
          when "1"
            @reportRows = StockInputDetail.get_kardex_yearly(1, @user, @report_type, @date_type, @since_date, @to_date, @cost_centers, @warehouses, @suppliers, @years, @periods, @formats, @articles, @moneys)
            case @report_type
              when "4" then
              render(partial: 'show_group_kardex_yearly', :layout => false)
              when "5" then
              render(partial: 'show_row_kardex_yearly', :layout => false)
            end
          when "2"
            @reportRows = StockInputDetail.get_kardex_monthly(1, @user, @report_type, @date_type, @since_date, @to_date, @cost_centers, @warehouses, @suppliers, @years, @periods, @formats, @articles, @moneys)
            case @report_type
              when "4" then
              render(partial: 'show_group_kardex_monthly', :layout => false)
              when "5" then
              render(partial: 'show_row_kardex_monthly', :layout => false)
            end
          when "3"
            @reportRows = StockInputDetail.get_kardex_daily(1, @user, @report_type, @date_type, @since_date, @to_date, @cost_centers, @warehouses, @suppliers, @years, @periods, @formats, @articles, @moneys)
            case @report_type
              when "4" then
              render(partial: 'show_group_kardex_daily', :layout => false)
              when "5" then
              render(partial: 'show_row_kardex_daily', :layout => false)
            end
          when "4"
            @reportRows = StockInputDetail.get_kardex_summary(1, @user, @report_type, @date_type, @since_date, @to_date, @cost_centers, @warehouses, @suppliers, @years, @periods, @formats, @articles, @moneys)
            case @report_type
              when "4" then
              render(partial: 'show_group_kardex_summary', :layout => false)
              when "5" then
              render(partial: 'show_row_kardex_detail', :layout => false)
            end
        end
      when "2" # Export PDF
        # Previous save filters
        # -> Json -> show_rows_results_pdf / show_group_results_pdf
        cache = ActiveSupport::Cache::MemoryStore.new(expires_in: 20.minutes)
        Rails.cache.write('since_date', @since_date)
        Rails.cache.write('to_date', @to_date)
        render :json => nil
    end
    #elsif params[:report_type] == "4" # Stock
    #  @reportRows = StockInputDetail.get_stocks(@user, @since_date, @to_date, @document)
    #  render(partial: 'show_rows_stock', :layout => false)
    #end

  end

  def show_rows_results_pdf
    @user = current_user.id

    @report_type = params[:id][0,1]
    @kardex_type = params[:id][1,1]
    @date_type = params[:id][2,1]

    @since_date = Rails.cache.read('since_date')#Date.strptime("01/01/1900", '%d/%m/%Y')
    @to_date = Rails.cache.read('to_date')  #Date.strptime("31/12/2050", '%d/%m/%Y')

    case @kardex_type
      when "1"
        @rows_per_page = 23
        @reportRows = StockInputDetail.get_kardex_yearly(0, @user, @report_type, @date_type, @since_date, @to_date, "", "", "", "", "", "", "", "")
      when "2"
        @rows_per_page = 23
        @reportRows = StockInputDetail.get_kardex_monthly(0, @user, @report_type, @date_type, @since_date, @to_date, "", "", "", "", "", "", "", "")
      when "3"
        @rows_per_page = 23
        @reportRows = StockInputDetail.get_kardex_daily(0, @user, @report_type, @date_type, @since_date, @to_date, "", "", "", "", "", "", "", "")
      when "4"
        @rows_per_page = 23
        @reportRows = StockInputDetail.get_kardex_summary(0, @user, @report_type, @date_type, @since_date, @to_date, "", "", "", "", "", "", "", "")
    end    

    prawnto inline: true, :prawn => { :page_size => 'A4', :page_layout => :landscape, :margin => [10, 40, 50, 40] }
  end

  def show_group_results_pdf
    @user = current_user.id

    @report_type = params[:id][0,1]
    @kardex_type = params[:id][1,1]
    @date_type = params[:id][2,1]

    @since_date = Rails.cache.read('since_date')#Date.strptime("01/01/1900", '%d/%m/%Y')
    @to_date = Rails.cache.read('to_date')  #Date.strptime("31/12/2050", '%d/%m/%Y')

    case @kardex_type
      when "1"
        @rows_per_page = 23
        @reportRows = StockInputDetail.get_kardex_yearly(0, @user, @report_type, @date_type, @since_date, @to_date, "", "", "", "", "", "", "", "")
      when "2"
        @rows_per_page = 23
        @reportRows = StockInputDetail.get_kardex_monthly(0, @user, @report_type, @date_type, @since_date, @to_date, "", "", "", "", "", "", "", "")
      when "3"
        @rows_per_page = 23
        @reportRows = StockInputDetail.get_kardex_daily(0, @user, @report_type, @date_type, @since_date, @to_date, "", "", "", "", "", "", "", "")
      when "4"
        @rows_per_page = 23
        @reportRows = StockInputDetail.get_kardex_summary(0, @user, @report_type, @date_type, @since_date, @to_date, "", "", "", "", "", "", "", "")
    end    
    
    prawnto inline: true, :prawn => { :page_size => 'A4', :page_layout => :landscape, :margin => [10, 40, 50, 40] }
  end

end
