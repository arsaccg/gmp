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
    article_hash = Array.new
    articles = Article.all
    articles.each do |art|
      article_hash << {'id' => art[0].to_s+'-'+art[3].to_s, 'code' => art[1], 'name' => art[2], 'symbol' => art[4]}
    end
    render json: {:articles => article_hash}
  end

  def add_order_item
    @reg_n = ((Time.now.to_f)*100).to_i
    data_article_unit = params[:article_id].split('-')
    @article = Article.find_article_in_specific(data_article_unit[0], get_company_cost_center('cost_center'))
    @sectors = Sector.where("code LIKE '__' ")
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center')).sort
    @amount = params[:amount].to_f
    @quantity = params[:quantity].to_i
    @article.each do |art|
      @code_article, @name_article, @id_article = art[3], art[1], art[2]
    end
    @unitOfMeasurement = UnitOfMeasurement.find(data_article_unit[1]).symbol
    @unitOfMeasurementId = data_article_unit[1]
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