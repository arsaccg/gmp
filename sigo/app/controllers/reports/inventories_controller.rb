class Reports::InventoriesController < ApplicationController
  def index
    @company = get_company_cost_center('company')
    @cost_center = get_company_cost_center('cost_center')
    @warehouses = Warehouse.where("cost_center_id = "+@cost_center.to_s)
    #@suppliers = TypeEntity.find_by_preffix('P').entities
    #@responsibles = TypeEntity.find_by_preffix('T').entities
    @years = Array.new
    (2000..2050).each do |x|
      @years << x
    end
    @periods = LinkTime.group(:year, :month).uniq
    @formats = Format.all
    #@articles = Article.get_article_per_type_distinct('02',session[:cost_center])
    #@moneys = Money.all
    render layout: false
  end

  def show

  end

  def display_articles
    word = params[:q]
    article_hash = Array.new
    articles = Article.get_article_todo_per_type_concat('02', word)
    articles.each do |x|
      article_hash << {'id' => x[0].to_s, 'code' => x[1], 'name' => x[2], 'symbol' => x[4]}
    end
    render json: {:articles => article_hash}
  end

  def display_suppliers
    word = params[:q]
    supplier_hash = Array.new
    type_ent = TypeEntity.find_by_preffix('P').id
    suppliers = ActiveRecord::Base.connection.execute("
            SELECT ent.id, ent.name, ent.ruc
            FROM entities ent, entities_type_entities ete
            WHERE ete.type_entity_id = " + type_ent.to_s + "
            AND ete.entity_id = ent.id
            AND Concat(ent.ruc, ' ', ent.name) LIKE '%" + word.to_s + "%'"
          )
    suppliers.each do |x|
      supplier_hash << {'id' => x[0].to_s, 'name' => x[1], 'ruc' => x[2]}
    end
    render json: {:suppliers => supplier_hash}
  end

  def display_responsibles
    word = params[:q]
    responsible_hash = Array.new
    type_ent = TypeEntity.find_by_preffix('T').id

    @cost_center = get_company_cost_center('cost_center')
    responsibles = Entity.joins(:workers).where("workers.cost_center_id = ?",@cost_center)

    responsibles.each do |x|
      responsible_hash << {'id' => x.id.to_s, 'dni' => x.dni, 'name' => x.name + ' ' + x.second_name + ' ' + x.paternal_surname + ' ' + x.maternal_surname}
    end
    render json: {:responsibles => responsible_hash}
  end

  def show_rows_results
    @company = get_company_cost_center('company')
    @cost_center = get_company_cost_center('cost_center')
    @user = current_user.id

    #-------------------------------
    # CostCenter
    #-------------------------------
    #@cost_centers = ""
    #if params[:cost_center_id] != ""
    #  @cost_centers = ","
    #  params[:cost_center_id].each.with_index(1) do |x, i|
    #    @cost_centers += x.to_s + ","
    #  end
    #end
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
      @suppliers = "," + params[:supplier_id] + ","
      #params[:supplier_id].each.with_index(1) do |x, i|
      #  @suppliers += x.to_s + ","
      #end
    end
    #-------------------------------
    # Responsible
    #-------------------------------
    @responsibles = ""
    if params[:responsible_id] != ""
      @responsibles = "," + params[:responsible_id] + ","
      #params[:responsible_id].each.with_index(1) do |x, i|
      #  @responsibles += x.to_s + ","
      #end
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
      @articles = "," + params[:article_id] + ","
      #params[:article_id].each.with_index(1) do |x, i|
      #  @articles += x.to_s + ","
      #end
    end
    #  Article.joins(:type_of_article).where("type_of_articles.code" => "02").all.each do |x|
    #-------------------------------
    # Money
    #-------------------------------
    @moneys = ""
    #if params[:money_id] != ""
    #  @moneys = ","
    #  params[:money_id].each.with_index(1) do |x, i|
    #    @moneys += x.to_s + ","
    #  end
    #end
    #-------------------------------
    #logger.info "PARAMETROS---:" + params[:since_date] 
    #logger.info "PARAMETROS---:" + params[:to_date] 
    
    if params[:since_date] != ""
      @since_date = params[:since_date]#Date.strptime(params[:since_date], '%Y%d%m')
    else
      @since_date = Date.strptime("1900-01-01", '%Y-%m-%d')
    end if
    
    if params[:to_date] != ""
      @to_date = params[:to_date]#Date.strptime(params[:to_date], '%Y%d%m')
    else
      @to_date = Date.strptime("2050-12-31", '%Y-%m-%d')
    end if
    @series = "" #params[:series]
    @document = "" #params[:document]

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
            @reportRows = StockInputDetail.get_kardex_yearly(1, @company, @cost_center, @user, @report_type, @date_type, @since_date, @to_date, @warehouses, @suppliers, @responsibles, @years, @periods, @formats, @articles, @moneys)
            case @report_type
              when "4" then
              render(partial: 'show_group_kardex_yearly', :layout => false)
              when "5" then
              render(partial: 'show_row_kardex_yearly', :layout => false)
            end
          when "2"
            @reportRows = StockInputDetail.get_kardex_monthly(1, @company, @cost_center, @user, @report_type, @date_type, @since_date, @to_date, @warehouses, @suppliers, @responsibles, @years, @periods, @formats, @articles, @moneys)
            case @report_type
              when "4" then
              render(partial: 'show_group_kardex_monthly', :layout => false)
              when "5" then
              render(partial: 'show_row_kardex_monthly', :layout => false)
            end
          when "3"
            @reportRows = StockInputDetail.get_kardex_daily(1, @company, @cost_center, @user, @report_type, @date_type, @since_date, @to_date, @warehouses, @suppliers, @responsibles, @years, @periods, @formats, @articles, @moneys)
            case @report_type
              when "4" then
              render(partial: 'show_group_kardex_daily', :layout => false)
              when "5" then
              render(partial: 'show_row_kardex_daily', :layout => false)
            end
          when "4"
            @reportRows = StockInputDetail.get_kardex_summary(1, @company, @cost_center, @user, @report_type, @date_type, @since_date, @to_date, @warehouses, @suppliers, @responsibles, @years, @periods, @formats, @articles, @moneys)
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
        Rails.cache.write('warehouses', @warehouses)
        Rails.cache.write('suppliers', @suppliers)
        Rails.cache.write('responsibles', @responsibles)
        Rails.cache.write('years', @years)
        Rails.cache.write('periods', @periods)
        Rails.cache.write('formats', @formats)
        Rails.cache.write('articles', @articles)
        Rails.cache.write('moneys', @moneys)

        #logger.info "@periods: " + @periods

        render :json => nil
    end
    #elsif params[:report_type] == "4" # Stock
    #  @reportRows = StockInputDetail.get_stocks(@user, @since_date, @to_date, @document)
    #  render(partial: 'show_rows_stock', :layout => false)
    #end

  end

  def show_rows_results_pdf
    @company = get_company_cost_center('company')
    @cost_center = get_company_cost_center('cost_center')
    @user = current_user.id

    @report_type = params[:id][0,1]
    @kardex_type = params[:id][1,1]
    @date_type = params[:id][2,1]

    @since_date = Rails.cache.read('since_date') #Date.strptime("01/01/1900", '%d/%m/%Y')
    @to_date = Rails.cache.read('to_date')  #Date.strptime("31/12/2050", '%d/%m/%Y')
    @warehouses = Rails.cache.read('warehouses')
    @suppliers = Rails.cache.read('suppliers')
    @responsibles = Rails.cache.read('responsibles')
    @years = Rails.cache.read('years')
    @periods = Rails.cache.read('periods')
    @formats = Rails.cache.read('formats')
    @articles = Rails.cache.read('articles')
    @moneys = Rails.cache.read('moneys')

    #logger.info "@periods cache: " + Rails.cache.read('periods')

    case @kardex_type
      when "1"
        @rows_per_page = 23
        @reportRows = StockInputDetail.get_kardex_yearly(0, @company, @cost_center, @user, @report_type, @date_type, @since_date, @to_date, @warehouses, @suppliers, @responsibles, @years, @periods, @formats, @articles, @moneys)
      when "2"
        @rows_per_page = 23
        @reportRows = StockInputDetail.get_kardex_monthly(0, @company, @cost_center, @user, @report_type, @date_type, @since_date, @to_date, @warehouses, @suppliers, @responsibles, @years, @periods, @formats, @articles, @moneys)
      when "3"
        @rows_per_page = 23
        @reportRows = StockInputDetail.get_kardex_daily(0, @company, @cost_center, @user, @report_type, @date_type, @since_date, @to_date, @warehouses, @suppliers, @responsibles, @years, @periods, @formats, @articles, @moneys)
      when "4"
        @rows_per_page = 23
        @reportRows = StockInputDetail.get_kardex_summary(0, @company, @cost_center, @user, @report_type, @date_type, @since_date, @to_date, @warehouses, @suppliers, @responsibles, @years, @periods, @formats, @articles, @moneys)
    end    

    prawnto inline: true, :prawn => { :page_size => 'A4', :page_layout => :landscape, :margin => [10, 40, 50, 40] }
  end

  def show_group_results_pdf
    @company = get_company_cost_center('company')
    @cost_center = get_company_cost_center('cost_center')
    @user = current_user.id

    @report_type = params[:id][0,1]
    @kardex_type = params[:id][1,1]
    @date_type = params[:id][2,1]

    @since_date = Rails.cache.read('since_date') #Date.strptime("01/01/1900", '%d/%m/%Y')
    @to_date = Rails.cache.read('to_date') #Date.strptime("31/12/2050", '%d/%m/%Y')
    @warehouses = Rails.cache.read('warehouses')
    @suppliers = Rails.cache.read('suppliers')
    @responsibles = Rails.cache.read('responsibles')
    @years = Rails.cache.read('years')
    @periods = Rails.cache.read('periods')
    @formats = Rails.cache.read('formats')
    @articles = Rails.cache.read('articles')
    @moneys = Rails.cache.read('moneys')

    #logger.info "@periods cache: " + Rails.cache.read('periods')
    
    case @kardex_type
      when "1"
        @rows_per_page = 23
        @reportRows = StockInputDetail.get_kardex_yearly(0, @company, @cost_center, @user, @report_type, @date_type, @since_date, @to_date, @warehouses, @suppliers, @responsibles, @years, @periods, @formats, @articles, @moneys)
      when "2"
        @rows_per_page = 23
        @reportRows = StockInputDetail.get_kardex_monthly(0, @company, @cost_center, @user, @report_type, @date_type, @since_date, @to_date, @warehouses, @suppliers, @responsibles, @years, @periods, @formats, @articles, @moneys)
      when "3"
        @rows_per_page = 23
        @reportRows = StockInputDetail.get_kardex_daily(0, @company, @cost_center, @user, @report_type, @date_type, @since_date, @to_date, @warehouses, @suppliers, @responsibles, @years, @periods, @formats, @articles, @moneys)
      when "4"
        @rows_per_page = 23
        @reportRows = StockInputDetail.get_kardex_summary(0, @company, @cost_center, @user, @report_type, @date_type, @since_date, @to_date, @warehouses, @suppliers, @responsibles, @years, @periods, @formats, @articles, @moneys)
    end    
    
    prawnto inline: true, :prawn => { :page_size => 'A4', :page_layout => :landscape, :margin => [10, 40, 50, 40] }
  end

end
