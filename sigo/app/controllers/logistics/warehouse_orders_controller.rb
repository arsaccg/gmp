class Logistics::WarehouseOrdersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    @cost_center = CostCenter.find(get_company_cost_center('cost_center'))
    @stock_input = StockInput.first
    @warehouse_orders = WarehouseOrder.where('cost_center_id=?', @cost_center)
    render layout: false
  end

  def new
    @cost_center = CostCenter.find(get_company_cost_center('cost_center')) rescue nil
    @warehouse_order = WarehouseOrder.new
    @working_groups = WorkingGroup.all
    render layout: false
  end

  def create
    warehouse_order = WarehouseOrder.new(warehouse_order_params)
    if warehouse_order.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index, :controller => "warehouse_orders"
    else
      gexp.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @warehouse_order = warehouse_order
      render :new, layout: false 
    end
  end

  def update
    warehouse_order = WarehouseOrder.find(params[:id])
    if warehouse_order.update_attributes(warehouse_order_params)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, :controller => "warehouse_orders"
    else
      con.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @warehouse_order = warehouse_order
      render :edit, layout: false
    end
  end

  def edit
    @cost_center = CostCenter.find(get_company_cost_center('cost_center'))
    @reg_n=((Time.now.to_f)*100).to_i
    @warehouse_order = WarehouseOrder.find(params[:id])
    @sectors = Sector.all
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center'))
    @action = 'edit'
    @working_groups = WorkingGroup.all
    render layout: false
  end


  def display_articles
    word = params[:q]
    @cost_center = get_company_cost_center('cost_center')
    article_hash = Array.new
    @ids=Array.new
    @warehouses = Warehouse.where(cost_center_id: "#{@cost_center}")
    @warehouses.each do |ware|
      @inputs=StockInput.where(warehouse_id: "#{ware.id}")
        @inputs.each do |stock|
          @inputdetails=StockInputDetail.where(id: "#{stock.id}")
           @inputdetails.each do |details|
             @article=Article.find_by_id("#{details.article_id}")
             @ids << @article.id
            end
        end
    end
    @ids = @ids.uniq.join(',')
    articles = Article.where('id IN ('+@ids+') AND name LIKE ("%'+word+'%") OR code LIKE ("%'+word+'%")')
    articles.each do |art|
      article_hash << {'id' => art.id.to_s, 'code' => art.code, 'name' => art.name, 'symbol' => art.unit_of_measurement.symbol}
    end
    puts "-------------------------------------------------------------"
    article_hash.each do |art|
      puts art
    end
    puts "-------------------------------------------------------------"
    
    render json: {:articles => article_hash}
  end

  def add_order_item
    article = Array.new
    result = 0.0
    name = ""
    @articleresult = Array.new
    sum = 0
    rest = 0
    stockinputdetail = StockInputDetail.all
    stockinputdetail.each do |si|
      article << si.article_id
    end
    article = article.uniq
    article.each do |art|
      name = Article.find(art).name
      id = Article.find(art).id
      sisum = StockInput.where("input = 1")
      sisum.each do |sis|
        sis.stock_input_details.each do |sisd|
          if sisd.article_id == art
            sum += sisd.amount
          end
        end
      end
      sires = StockInput.where("input = 0")
      sires.each do |sir|
        sir.stock_input_details.each do |sird|
          if sird.article_id == art
            rest += sird.amount
          end
        end
      end
      result = sum - rest
      sum = 0
      rest = 0
      @articleresult << [id,result]
    end
    #@articleresult = [article,name,result]

    @reg_n = ((Time.now.to_f)*100).to_i
    data_article_unit = params[:article_id]
    @article = Article.find(data_article_unit)
    @sectors = Sector.where("code LIKE '__' ")
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center')).sort
    @amount = params[:amount].to_f
    @quantity = params[:quantity].to_i
    @stockamount = StockInputDetail.sum(:amount, :conditions => 'article_id ='+@article.id.to_s)
    @code_article, @name_article, @id_article = @article.code, @article.name, @article.id
    @unitOfMeasurement = UnitOfMeasurement.find(@article.unit_of_measurement_id).symbol
    @unitOfMeasurementId = @article.unit_of_measurement_id
    render(partial: 'warehouse_order_items', :layout => false)
  end

  def destroy
    warehouse_order = WarehouseOrder.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el pedido seleccionado."
    render :json => warehouse_order
  end



  def show
    @warehouse_order = WarehouseOrder.find(params[:id])
    @warehouse_order_details = @warehouse_order.warehouse_order_details
    render layout: false
  end

  private

  def warehouse_order_params
    params.require(:warehouse_order).permit(:code,:working_group_id,:date,:cost_center_id, warehouse_order_details_attributes:[:id, :article_id,:quantity,:sector_id,:phase_id,:warehouse_order_id, :_destroy])
  end


end