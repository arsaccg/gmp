class Reports::InventoriesController < ApplicationController
  def index
    @cost_centers = CostCenter.all
    @warehouses = Warehouse.all
    @suppliers = Entity.joins(:type_entities).where("type_entities.preffix" => "P")
    @responsibles = Entity.joins(:type_entities).where("type_entities.preffix" => "P")
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

  def show_rows_results2
    @user = current_user.id

    #-------------------------------
    # Period Closure
    #-------------------------------
  end

  def show_rows_results
    @user = current_user.id

    #-------------------------------
    # CostCenter
    #-------------------------------
    #RepInvCostCenter.delete_all ({user: @user})
    #if params[:cost_center_id] != ""
    #  params[:cost_center_id].each.with_index(1) do |x, i|
    #    e = CostCenter.find(x.to_i)
    #    RepInvCostCenter.create({user: @user, id: e.id, name: e.name})
    #  end
    #else
    #  CostCenter.all.each do |x|
    #    RepInvCostCenter.create({user: @user, id: x.id, name: x.name})
    #  end
    #end
    #-------------------------------
    # Warehouses
    #-------------------------------
    RepInvWarehouse.delete_all ({user: @user})
    if params[:warehouse_id] != ""
      params[:warehouse_id].each.with_index(1) do |x, i|
        e = Warehouse.find(x.to_i)
        RepInvWarehouse.create({user: @user, id: e.id, name: e.name})
      end
    else
      Warehouse.all.each do |x|
        RepInvWarehouse.create({user: @user, id: x.id, name: x.name})
      end
    end
    #-------------------------------
    # Supplier
    #-------------------------------
    RepInvSupplier.delete_all ({user: @user})
    if params[:supplier_id] != ""
      params[:supplier_id].each.with_index(1) do |x, i|
        e = Entity.find(x.to_i)
        RepInvSupplier.create({user: @user, id: e.id, name: e.name})
      end
    else
      Entity.joins(:type_entities).where("type_entities.preffix" => "P").all.each do |x|
        RepInvSupplier.create({user: @user, id: x.id, name: x.name})
      end
    end
    #-------------------------------
    # Year
    #-------------------------------
    RepInvYear.delete_all ({user: @user})
    if params[:year_id] != ""
      params[:year_id].each.with_index(1) do |x, i|
        RepInvYear.create({user: @user, id: x.to_i})
      end
    else
      LinkTime.group(:year).uniq.all.each do |x|
        RepInvYear.create({user: @user, id: x.year})
      end
    end
    #-------------------------------
    # Period
    #-------------------------------
    RepInvPeriod.delete_all ({user: @user})
    if params[:period_id] != ""
      params[:period_id].each.with_index(1) do |x, i|
        RepInvPeriod.create({user: @user, id: x.to_i, name: x.to_i})
      end
    else
      LinkTime.group(:year, :month).uniq.all.each do |x|
        RepInvPeriod.create({user: @user, id: x.year * 100 + x.month, name: x.year * 100 + x.month})
      end
    end
    #-------------------------------
    # Format
    #-------------------------------
    RepInvFormat.delete_all ({user: @user})
    if params[:format_id] != ""
      params[:format_id].each.with_index(1) do |x, i|
        e = Format.find(x.to_i)
        RepInvFormat.create({user: @user, id: e.id, name: e.name})
      end
    else
      Format.all.each do |x|
        RepInvFormat.create({user: @user, id: x.id, name: x.name})
      end
    end
    #-------------------------------
    # Articles
    #-------------------------------
    RepInvArticle.delete_all ({user: @user})
    if params[:article_id] != ""
      params[:article_id].each.with_index(1) do |x, i|
        e = Entity.find(x.to_i)
        RepInvArticle.create({user: @user, id: e.id, name: e.name})
      end
    else
      Article.joins(:type_of_article).where("type_of_articles.code" => "02").all.each do |x|
        RepInvArticle.create({user: @user, id: x.id, name: x.name})
      end
    end
    #-------------------------------
    # Money
    #-------------------------------
    RepInvMoney.delete_all ({user: @user})
    if params[:money_id] != ""
      params[:money_id].each.with_index(1) do |x, i|
        e = Money.find(x.to_i)
        RepInvMoney.create({user: @user, id: e.id, name: e.name})
      end
    else
      Money.all.each do |x|
        RepInvMoney.create({user: @user, id: x.id, name: x.name})
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
            @reportRows = StockInputDetail.get_kardex_yearly(@user, @date_type, @since_date, @to_date)
            render(partial: 'show_rows_kardex_yearly', :layout => false)
          when "2"
            @reportRows = StockInputDetail.get_kardex_monthly(@user, @date_type, @since_date, @to_date)
            render(partial: 'show_rows_kardex_monthly', :layout => false)
          when "3"
            @reportRows = StockInputDetail.get_kardex_detail(@user, @date_type, @since_date, @to_date)
            render(partial: 'show_rows_kardex_detail', :layout => false)
        end
      when "2" # Export PDF
        # Previous save filters
        # -> Json -> show_rows_results_pdf
        render :json => nil
    end
    #elsif params[:report_type] == "4" # Stock
    #  @reportRows = StockInputDetail.get_stocks(@user, @since_date, @to_date, @document)
    #  render(partial: 'show_rows_stock', :layout => false)
    #end

  end

  def show_rows_results_pdf
    @user = current_user.id

    @kardex_type = params[:id][0,1]
    @date_type = params[:id][1,1]

    @from_date = Date.strptime("01/01/1900", '%d/%m/%Y')
    @to_date = Date.strptime("31/12/2050", '%d/%m/%Y')

    case @kardex_type
      when "1"
        @rows_per_page = 23
        @reportRows = StockInputDetail.get_kardex_yearly(@user, @date_type, @from_date, @to_date)
      when "2"
        @rows_per_page = 23
        @reportRows = StockInputDetail.get_kardex_monthly(@user, @date_type, @from_date, @to_date)
      when "3"
        @rows_per_page = 23
        @reportRows = StockInputDetail.get_kardex_detail(@user, @date_type, @from_date, @to_date)
    end    
    
    prawnto inline: true, :prawn => { :page_size => 'A4', :page_layout => :landscape, :margin => [10, 40, 50, 40] }
  end
end
