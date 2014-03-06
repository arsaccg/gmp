class Logistics::DeliveryOrdersController < ApplicationController
  def index
    @deliveryOrders = DeliveryOrder.where("user_id = ?", "#{current_user.id}")
    if params[:task] == 'created' || params[:task] == 'edited' || params[:task] == 'failed' || params[:task] == 'canceled' || params[:task] == 'approved' || params[:task] == 'revised'
      render layout: 'dashboard'
    else
      render layout: false
    end
  end

  def new
    @deliveryOrder = DeliveryOrder.new
    @articles = Article.all
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
    @deliveryOrder = DeliveryOrder.find(params[:id])
    @deliveryOrderDetails = DeliveryOrderDetail.where("delivery_order_id = ?", @deliveryOrder.id)
    render :show
  end

  def edit
    @deliveryOrder = DeliveryOrder.find(params[:id])
    @articles = Article.all
    @sectors = Sector.all
    @phases = Phase.where("category LIKE 'phase'")
    @action = 'edit'
    render layout: false
  end

  def update
    deliveryOrder = DeliveryOrder.find(params[:id])
    deliveryOrder.update_attributes(delivery_order_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index, :task => 'edited'
  end

  def add_delivery_order_item_field
    @reg_n = Time.now.to_i
    @article = Article.find(params[:article_id])
    @sectors = Sector.all
    @phases = Phase.where("category LIKE 'phase'")
    @amount = params[:amount].to_f

    @code_article, @name_article, @id_article, @unitOfMeasurement, @unitOfMeasurementId = @article.code, @article.name, @article.id, @article.unit_of_measurement.name, @article.unit_of_measurement.id
    
    render(partial: 'delivery_order_items', :layout => false)
  end

  # Este es el cambio de estado
  def destroy
    @deliveryOrder = DeliveryOrder.find_by_id(params[:id])
    @deliveryOrder.update_attributes(:state => "canceled")
    redirect_to :action => :index, :task => 'canceled'
  end

  def gorevise
    @deliveryOrder = DeliveryOrder.find_by_id(params[:id])
    @deliveryOrder.update_attributes(:state => "revised")
    redirect_to :action => :index, :task => 'revised'
  end

  def goapprove
    @deliveryOrder = DeliveryOrder.find_by_id(params[:id])
    @deliveryOrder.update_attributes(:state => "approved")
    redirect_to :action => :index, :task => 'approved'
  end

  private
  def delivery_order_parameters
    params.require(:delivery_order).permit(:date_of_issue, :scheduled, :description, delivery_order_details_attributes: [:id, :delivery_order_id, :article_id, :unit_of_measurement_id, :sector_id, :phase_id, :description, :amount])
  end
end
