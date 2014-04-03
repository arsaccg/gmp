class Logistics::DeliveryOrdersController < ApplicationController
  def index
    @article = Article.first
    @phase = Phase.first
    @sector = Sector.first
    @costcenters = CostCenter.where("company_id = #{params[:company_id]}")
    @centerOfAttention = CenterOfAttention.all.first
    render layout: false
  end

  def new
    @company = params[:company_id]
    @deliveryOrder = DeliveryOrder.new
    @articles = Article.all
    @costcenters = Company.find(@company).cost_centers
    render layout: false
  end

  def create
    deliveryOrder = DeliveryOrder.new(delivery_order_parameters)
    deliveryOrder.state
    deliveryOrder.user_id = current_user.id
    if deliveryOrder.save
      flash[:notice] = "Se ha creado correctamente la nueva orden de suministro."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => :index, company_id: params[:company_id]
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
    @costcenters = Company.find(params[:company_id]).cost_centers
    @action = 'edit'
    render layout: false
  end

  def update
    deliveryOrder = DeliveryOrder.find(params[:id])
    deliveryOrder.update_attributes(delivery_order_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index
  end

  def show_rows_delivery_orders
    @deliveryOrders = Array.new
    if !params[:pending]
      Company.find(params[:company_id]).cost_centers.find(params[:cost_center_id]).delivery_orders.each do |delivery_order|
        @deliveryOrders << delivery_order
      end
      render(partial: 'rows_delivery_orders', :layout => false)
    else
      Company.find(params[:company_id]).cost_centers.find(params[:cost_center_id]).delivery_orders.where("state LIKE 'approved'").each do |delivery_order|
        @deliveryOrders << delivery_order
      end
      render(partial: 'rows_tracking_delivery_orders', :layout => false)
    end
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

  def show_tracking_orders
    @costcenters = CostCenter.where("company_id = #{params[:id]}")
    @deliveryOrders = Array.new
    Company.find(params[:id]).cost_centers.each do |cost_center|
      @deliveryOrders << cost_center.delivery_orders.where("state LIKE 'approved'")
    end
    render :tracing_orders, :layout => false
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

    if @deliveryOrder.state == 'pre_issued'
      @state_per_order_details_approved = @deliveryOrder.state_per_order_details.where("state LIKE 'pre_issued'").last
      @state_per_order_details_revised = @deliveryOrder.state_per_order_details.where("state LIKE 'pre_issued'").last

      if @state_per_order_purchase_approved == nil && @state_per_order_purchase_revised == nil
        @state_per_order_purchase_approved = @deliveryOrder
        @state_per_order_purchase_revised = @deliveryOrder
      end

      @first_state = "Pre-Emitido"
      @second_state = "Pre-Emitido"
    end

    if @deliveryOrder.state == 'issued'
      @state_per_order_details_approved = @deliveryOrder.state_per_order_details.where("state LIKE 'issued'").last
      @state_per_order_details_revised = @deliveryOrder.state_per_order_details.where("state LIKE 'pre_issued'").last
      @first_state = "Emitido"
      @second_state = "Pre-Emitido"
    end

    if @deliveryOrder.state == 'revised'
      @state_per_order_details_approved = @deliveryOrder.state_per_order_details.where("state LIKE 'revised'").last
      @state_per_order_details_revised = @deliveryOrder.state_per_order_details.where("state LIKE 'issued'").last
      @first_state = "Revisado"
      @second_state = "Emitido"
    end

    if @deliveryOrder.state == 'approved'
      @state_per_order_details_approved = @deliveryOrder.state_per_order_details.where("state LIKE 'approved'").last
      @state_per_order_details_revised = @deliveryOrder.state_per_order_details.where("state LIKE 'revised'").last
      @first_state = "Aprobado"
      @second_state = "Revisado"
    end

    if @deliveryOrder.state == 'canceled'
      @state_per_order_details_approved = @deliveryOrder.state_per_order_details.where("state LIKE 'canceled'").last
      @state_per_order_details_revised = @deliveryOrder.state_per_order_details.where("state LIKE 'canceled'").last
      @first_state = "Cancelado"
      @second_state = "Cancelado"
    end
    
  end

  private
  def delivery_order_parameters
    params.require(:delivery_order).permit(:date_of_issue, :scheduled, :description, :cost_center_id, delivery_order_details_attributes: [:id, :delivery_order_id, :article_id, :unit_of_measurement_id, :sector_id, :phase_id, :description, :amount, :scheduled_date, :center_of_attention_id])
  end
end
