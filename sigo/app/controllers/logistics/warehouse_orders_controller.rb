class Logistics::WarehouseOrdersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    @stock_input = StockInput.first
    @warehouse_orders = WarehouseOrder.all
    render layout: false
  end

  def new
    @warehouse_order = WarehouseOrder.new
    @working_groups = WorkingGroup.all
    render layout: false
  end

  def create
    warehouse_order = WarehouseOrder.new(warehouse_order_params)
    if warehouse_order.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index, :controller => "cost_centers"
    else
      gexp.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @warehouse_order = warehouse_order
      render :new, layout: false 
    end
  end

  def update
    cost_center_detail = CostCenterDetail.find(params[:id])
    if cost_center_detail.update_attributes(cost_center_detail_params)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, :controller => "cost_centers"
    else
      con.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @cost_center_detail = cost_center_detail
      render :edit, layout: false
  end

  def edit
    @reg_n=((Time.now.to_f)*100).to_i
    @cost_center_detail = CostCenterDetail.find(params[:id])
    @action = 'edit'
    @working_groups = WorkingGroup.all
    render layout: false
  end

  def add_order_item
  end

  def destroy
  end



  def show
  end

  private

  def warehouse_order_params
    params.require(:warehouse_order).permit(:code,:working_group_id,:date, warehouse_order_details_attributes:[:id, :article_id,:quantity,:sector_id,:phase_id,:warehouse_order_id])
  end

end
end