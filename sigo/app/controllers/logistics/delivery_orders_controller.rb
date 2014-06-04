class Logistics::DeliveryOrdersController < ApplicationController
  def index
    @article = Article.first
    @phase = Phase.first
    @sector = Sector.first
    @company = get_company_cost_center('company')
    @cost_center = get_company_cost_center('cost_center')
    @deliveryOrders = DeliveryOrder.where("cost_center_id = ?",@cost_center)
    @centerOfAttention = CenterOfAttention.all.first
    render layout: false
  end

  def display_articles
    word = params[:q]
    article_hash = Array.new
    articles = DeliveryOrder.getOwnArticles(word, get_company_cost_center('cost_center'))
    articles.each do |art|
      article_hash << {'id' => art[0].to_s+'-'+art[3].to_s, 'code' => art[1], 'name' => art[2], 'symbol' => art[4]}
    end
    render json: {:articles => article_hash}
  end

  def new
    @company = params[:company_id]
    @cost_center = CostCenter.find(params[:cost_center_id])
    @deliveryOrder = DeliveryOrder.new
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
    @company = params[:company_id]
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
    @company = params[:company_id]
    @deliveryOrder = DeliveryOrder.find(params[:id])
    @sectors = Sector.all
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center'))
    @centerOfAttentions = CenterOfAttention.all
    @costcenters = Company.find(@company).cost_centers
    @action = 'edit'
    render layout: false
  end

  def update
    deliveryOrder = DeliveryOrder.find(params[:id])
    deliveryOrder.update_attributes(delivery_order_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index, company_id: params[:company_id]
  end

  def add_delivery_order_item_field
    @reg_n = Time.now.to_i
    data_article_unit = params[:article_id].split('-')
    @article = Article.find(data_article_unit[0])
    @sectors = Sector.where("code LIKE '__' ")
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center'))
    @amount = params[:amount].to_f
    @centerOfAttention = CenterOfAttention.all
    @code_article, @name_article, @id_article = @article.code, @article.name, @article.id
    @unitOfMeasurement = UnitOfMeasurement.find(data_article_unit[1]).symbol
    @unitOfMeasurementId = data_article_unit[1]
    
    render(partial: 'delivery_order_items', :layout => false)
  end

  def show_tracking_orders
    @cost_center = get_company_cost_center('cost_center')
    @deliveryOrders = DeliveryOrder.where("cost_center_id = ? AND state LIKE ?", @cost_center, 'approved')
    render :tracing_orders, :layout => false
  end

  # DO DELETE row
  def delete
    @deliveryOrder = DeliveryOrder.destroy(params[:id])
    @deliveryOrder.delivery_order_details.each do |dod|
      DeliveryOrderDetail.destroy(dod.id)
    end
    render :json => @deliveryOrder
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
    #redirect_to :action => :index, company_id: params[:company_id]
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
    redirect_to :action => :index, company_id: params[:company_id]
  end

  def gorevise
    @deliveryOrder = DeliveryOrder.find_by_id(params[:id])
    @deliveryOrder.revise
    stateOrderDetail = StatePerOrderDetail.new
    stateOrderDetail.state = @deliveryOrder.human_state_name
    stateOrderDetail.delivery_order_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index, company_id: params[:company_id]
  end

  def goapprove
    @deliveryOrder = DeliveryOrder.find_by_id(params[:id])
    @deliveryOrder.approve
    stateOrderDetail = StatePerOrderDetail.new
    stateOrderDetail.state = @deliveryOrder.human_state_name
    stateOrderDetail.delivery_order_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index, company_id: params[:company_id]
  end

  def goobserve
    @deliveryOrder = DeliveryOrder.find_by_id(params[:id])
    @deliveryOrder.observe
    stateOrderDetail = StatePerOrderDetail.new
    stateOrderDetail.state = @deliveryOrder.human_state_name
    stateOrderDetail.delivery_order_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index, company_id: params[:company_id]
  end

  def delivery_order_pdf
    @company = Company.find(params[:company_id])
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
      if @state_per_order_details_revised == nil
        @state_per_order_details_revised = @state_per_order_details_approved
      end
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
    params.require(:delivery_order).permit(:date_of_issue, :scheduled, :description, :cost_center_id, delivery_order_details_attributes: [:id, :delivery_order_id, :article_id, :unit_of_measurement_id, :sector_id, :phase_id, :description, :amount, :scheduled_date, :center_of_attention_id, :_destroy])
  end
end
