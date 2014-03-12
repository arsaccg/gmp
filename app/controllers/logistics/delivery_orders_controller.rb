class Logistics::DeliveryOrdersController < ApplicationController
  def index
    @deliveryOrders = DeliveryOrder.where("user_id = ?", "#{current_user.id}")
    @article = Article.first
    @phase = Phase.first
    @sector = Sector.first
    @centerOfAttention = CenterOfAttention.first
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
      stateOrderDetail.user_id = current_user.id
      stateOrderDetail.save
      flash[:notice] = "Se ha creado correctamente la nueva orden de suministro."
      redirect_to :action => :index
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => :index
    end
  end

  def show
    @deliveryOrder = DeliveryOrder.find(params[:id])
    if params[:state_change] != nil
      @state_change = params[:state_change]
    else
      @deliverPerState = @deliveryOrder.state_per_order_details
    end
    @deliveryOrderDetails = @deliveryOrder.delivery_order_details
    render layout: false
  end

  def edit
    @deliveryOrder = DeliveryOrder.find(params[:id])
    @articles = Article.all
    @sectors = Sector.all
    @phases = Phase.where("category LIKE 'phase'")
    @centerOfAttentions = CenterOfAttention.all
    @action = 'edit'
    render layout: false
  end

  def update
    deliveryOrder = DeliveryOrder.find(params[:id])
    deliveryOrder.update_attributes(delivery_order_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index
  end

  def add_delivery_order_item_field
    @reg_n = Time.now.to_i
    data_article_unit = params[:article_id].split('-')
    @article = Article.find(data_article_unit[0])
    @sectors = Sector.all
    @phases = Phase.where("category LIKE 'phase'")
    @amount = params[:amount].to_f
    @centerOfAttention = CenterOfAttention.all
    @code_article, @name_article, @id_article = @article.code, @article.name, @article.id
    @unitOfMeasurement = UnitOfMeasurement.find(data_article_unit[1]).name
    @unitOfMeasurementId = data_article_unit[1]
    
    render(partial: 'delivery_order_items', :layout => false)
  end

  # Este es el cambio de estado
  def destroy
    @deliveryOrder = DeliveryOrder.find_by_id(params[:id])
    @deliveryOrder.cancel
    stateOrderDetail = StatePerOrderDetail.new
    stateOrderDetail.state = @deliveryOrder.human_state_name
    stateOrderDetail.delivery_order_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    #redirect_to :action => :index
    render :json => @deliveryOrder
  end

  def goissue
    @deliveryOrder = DeliveryOrder.find_by_id(params[:id])
    @deliveryOrder.issue
    stateOrderDetail = StatePerOrderDetail.new
    stateOrderDetail.state = @deliveryOrder.human_state_name
    stateOrderDetail.delivery_order_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index
  end

  def gorevise
    @deliveryOrder = DeliveryOrder.find_by_id(params[:id])
    @deliveryOrder.revise
    stateOrderDetail = StatePerOrderDetail.new
    stateOrderDetail.state = @deliveryOrder.human_state_name
    stateOrderDetail.delivery_order_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index
  end

  def goapprove
    @deliveryOrder = DeliveryOrder.find_by_id(params[:id])
    @deliveryOrder.approve
    stateOrderDetail = StatePerOrderDetail.new
    stateOrderDetail.state = @deliveryOrder.human_state_name
    stateOrderDetail.delivery_order_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index
  end

  def goobserve
    @deliveryOrder = DeliveryOrder.find_by_id(params[:id])
    @deliveryOrder.observe
    stateOrderDetail = StatePerOrderDetail.new
    stateOrderDetail.state = @deliveryOrder.human_state_name
    stateOrderDetail.delivery_order_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index
  end

  def delivery_order_pdf
    @deliveryOrder = DeliveryOrder.find(params[:id])
    @deliveryOrderDetails = @deliveryOrder.delivery_order_details
  end

  private
  def delivery_order_parameters
    params.require(:delivery_order).permit(:date_of_issue, :scheduled, :description, delivery_order_details_attributes: [:id, :delivery_order_id, :article_id, :unit_of_measurement_id, :sector_id, :phase_id, :description, :amount, :scheduled_date, :center_of_attention_id])
  end
end
