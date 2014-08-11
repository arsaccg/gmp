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
    warehouse_order.state
    warehouse_order.user_id = current_user.id    
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
    article_hash = StockInput.get_articles_in_stock()
    render json: {:articles => article_hash}
  end

  def add_order_item
    @reg_n = ((Time.now.to_f)*100).to_i
    data_params = params[:article_id].split('-')
    data_article_unit = data_params[0]
    @stockamount = data_params[1]
    @article = Article.find(data_article_unit)
    @sectors = Sector.where("code LIKE '__' ")
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center')).sort
    @amount = params[:amount].to_f
    @quantity = params[:quantity].to_i
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

  def change_state
    @warehouse_order = WarehouseOrder.find(params[:id])
    if @warehouse_order.state == "issued"
      @next = 'approved'
      puts "----------------------------------------------------------------------------------"
      puts @next
      puts "----------------------------------------------------------------------------------"
      puts "----------------------------------------------------------------------------------"
      @warehouse_order.update_attributes(:state => 'approved')
      puts "----------------------------------------------------------------------------------"
    end
    stateOrderDetail = StatePerWarehouseOrder.new
    stateOrderDetail.state = @next
    stateOrderDetail.warehouse_order_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save    
    redirect_to :action => :index
  end

  private
  def warehouse_order_params
    params.require(:warehouse_order).permit(:code,:working_group_id,:date,:cost_center_id, warehouse_order_details_attributes:[:id, :article_id,:quantity,:sector_id,:phase_id,:warehouse_order_id, :_destroy])
  end


end