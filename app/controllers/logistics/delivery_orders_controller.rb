class Logistics::DeliveryOrdersController < ApplicationController
  def index
    @deliveryOrders = DeliveryOrder.where("user_id = ?", "#{current_user.id}")
    if params[:task] == 'created' || params[:task] == 'edited' || params[:task] == 'failed' || params[:task] == 'deleted'
      render layout: 'dashboard'
    else
      render layout: false
    end
  end

  def new
    @deliveryOrder = DeliveryOrder.new
    render layout: false
  end

  def create
    deliveryOrder = DeliveryOrder.new(delivery_order_parameters)
    deliveryOrder.state
    deliveryOrder.user_id = current_user.id
    if deliveryOrder.save
      # Agregando el detalle de estados
      stateOrderDetail = StatePerOrderDetail.new
      stateOrderDetail.state = deliveryOrder.state
      stateOrderDetail.delivery_order_id = deliveryOrder.id
      stateOrderDetail.save
      flash[:notice] = "Se ha creado correctamente la nueva orden de suministro."
      redirect_to :action => :index, :task => 'created'
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => :index, :task => 'failed'
    end
  end

  def show
    deliveryOrder = DeliveryOrder.find(params[:id])
    render :show
  end

  def edit
    @deliveryOrder = DeliveryOrder.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    deliveryOrder = DeliveryOrder.find(params[:id])
    deliveryOrder.update_attributes(delivery_order_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index, :task => 'edited'
  end

  def destroy
    deliveryOrder = DeliveryOrder.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente la orden de suministro."
    redirect_to :action => :index, :task => 'deleted'
  end

  private
  def delivery_order_parameters
    params.require(:deliveryOrder).permit(:date_of_issue, :scheduled, :description)
  end
end
