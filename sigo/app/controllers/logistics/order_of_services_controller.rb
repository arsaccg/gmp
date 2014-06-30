class Logistics::OrderOfServicesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @article = Article.first
    @phase = Phase.first
    @sector = Sector.first
    @company = get_company_cost_center('company')
    @cost_center = get_company_cost_center('cost_center')
    @orderOfServices = OrderOfService.where("cost_center_id = ?", @cost_center)
    render layout: false
  end

  def display_articles
    word = params[:q]
    article_hash = Array.new
    @cost_center = CostCenter.find(get_company_cost_center('cost_center'))
    @name = @cost_center.name.delete("^a-zA-Z0-9-").gsub("-","_").downcase.tr(' ', '_')
    articles = OrderOfService.getOwnArticles(word, @name)
    articles.each do |art|
      article_hash << {'id' => art[0].to_s+'-'+art[3].to_s, 'code' => art[1], 'name' => art[2], 'symbol' => art[4]}
    end
    render json: {:articles => article_hash}
  end

  def show
    @company = params[:company_id]
    @orderOfService = OrderOfService.find(params[:id])
    if params[:state_change] != nil
      @state_change = params[:state_change]
      if params[:type_of_order] != nil
        @type_of_order = params[:type_of_order]
      end
    else
      @orderOfServicePerState = @orderOfService.state_per_order_of_services
    end
    @orderOfServiceDetails = @orderOfService.order_of_service_details
    render layout: false
  end

  def new
    @company = get_company_cost_center('company')
    # Set default value
    @igv = 0.18+1
    @cost_center_id = get_company_cost_center('cost_center')
    @cost_center = CostCenter.find(@cost_center_id)
    @orderOfService = OrderOfService.new
    FinancialVariable.where("name LIKE '%IGV%'").each do |val|
      if val != nil
        @igv= val.value.to_f+1
      end
    end
    @methodOfPayments = MethodOfPayment.all
    TypeEntity.where("id = 1").each do |tent|
      @suppliers = tent.entities
    end
    @moneys = Money.all
    render layout: false
  end

  def create
    @orderOfService = OrderOfService.new(order_service_parameters)
    @orderOfService.state = 'pre_issued'
    @orderOfService.user_id = current_user.id
    if @orderOfService.save
      flash[:notice] = "Se ha creado correctamente la nueva orden de compra."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def add_order_service_item_field
    @reg_n = ((Time.now.to_f)*100).to_i
    data_article_unit = params[:article_id].split('-')
    @article = Article.find_article_in_specific(data_article_unit[0], get_company_cost_center('cost_center'))
    @sectors = Sector.where("code LIKE '__'")
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center'))
    @phases = @phases.sort! { |a,b| a.code <=> b.code }
    @amount = params[:amount].to_f
    @centerOfAttention = CenterOfAttention.all
    @unitOfMeasurement = UnitOfMeasurement.find(data_article_unit[1]).symbol
    @unitOfMeasurementId = data_article_unit[1]
    @article.each do |art|
      @code_article, @name_article, @id_article = art[3], art[1], art[2]
    end
    render(partial: 'order_service_items', :layout => false)
  end

  def edit
    @company = params[:company_id]
    @reg_n = ((Time.now.to_f)*100).to_i
    # Set default value
    @igv = 0.18+1
    @orderOfService = OrderOfService.find(params[:id])
    @sectors = Sector.all
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center'))
    @costcenters = Company.find(@company).cost_centers
    @methodOfPayments = MethodOfPayment.all
    @cost_center_id = @orderOfService.cost_center_id
    FinancialVariable.where("name LIKE '%IGV%'").each do |val|
      if val != nil
        @igv= val.value.to_f+1
      end
    end
    TypeEntity.where("id = 1").each do |tent|
      @suppliers = tent.entities
    end
    @moneys = Money.all
    @action = 'edit'
    render layout: false
  end

  def update
    orderOfService = OrderOfService.find(params[:id])
    orderOfService.update_attributes(order_service_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index, company_id: params[:company_id]
  end

  # Este es el cambio de estado
  def destroy
    @OrderOfService = OrderOfService.find_by_id(params[:id])
    @OrderOfService.cancel
    stateOrderDetail = StatePerOrderOfService.new
    stateOrderDetail.state = @OrderOfService.human_state_name
    stateOrderDetail.order_of_service_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    #redirect_to :action => :index, company_id: params[:company_id]
    render :json => @OrderOfService
  end

  def goissue
    @OrderOfService = OrderOfService.find_by_id(params[:id])
    @OrderOfService.issue
    stateOrderDetail = StatePerOrderOfService.new
    stateOrderDetail.state = @OrderOfService.human_state_name
    stateOrderDetail.order_of_service_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index, company_id: params[:company_id]
  end

  def gorevise
    @OrderOfService = OrderOfService.find_by_id(params[:id])
    @OrderOfService.revise
    stateOrderDetail = StatePerOrderOfService.new
    stateOrderDetail.state = @OrderOfService.human_state_name
    stateOrderDetail.order_of_service_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index, company_id: params[:company_id]
  end

  def goapprove
    @OrderOfService = OrderOfService.find_by_id(params[:id])
    @OrderOfService.approve
    stateOrderDetail = StatePerOrderOfService.new
    stateOrderDetail.state = @OrderOfService.human_state_name
    stateOrderDetail.order_of_service_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index, company_id: params[:company_id]
  end

  def goobserve
    @OrderOfService = OrderOfService.find_by_id(params[:id])
    @OrderOfService.observe
    stateOrderDetail = StatePerOrderOfService.new
    stateOrderDetail.state = @OrderOfService.human_state_name
    stateOrderDetail.order_of_service_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index, company_id: params[:company_id]
  end

  # DO DELETE row
  def delete
    @orderOfService = OrderOfService.destroy(params[:id])
    @orderOfService.order_of_service_details.each do |oos|
      OrderOfServiceDetail.destroy(oos.id)
    end
    render :json => @orderOfService
  end

  def order_service_pdf
    @company = Company.find(params[:company_id])
    @orderOfService = OrderOfService.find(params[:id])
    @orderServiceDetails = @orderOfService.order_of_service_details
    
    # Numerics/Text values for footer
    @total = 0
    @igv = 0
    @igv_neto = 0
    @orderServiceDetails.each do |osd|
      @total += osd.amount*osd.unit_price
    end
    FinancialVariable.where("name LIKE '%IGV%'").each do |val|
      if val != nil
        @igv= val.value.to_f
      else
        @igv = 0.18
      end
    end
    @igv_neto = @total*@igv
    @total_neto = @total - @igv_neto

    if @orderOfService.state == 'pre_issued'
      @state_per_order_purchase_approved = @orderOfService.state_per_order_of_services.where("state LIKE 'pre_issued'").last
      @state_per_order_purchase_revised = @orderOfService.state_per_order_of_services.where("state LIKE 'pre_issued'").last

      if @state_per_order_purchase_approved == nil && @state_per_order_purchase_revised == nil
        @state_per_order_purchase_approved = @orderOfService
        @state_per_order_purchase_revised = @orderOfService
      end

      @first_state = "Pre-Emitido"
      @second_state = "Pre-Emitido"
    end

    if @orderOfService.state == 'issued'
      @state_per_order_purchase_approved = @orderOfService.state_per_order_of_services.where("state LIKE 'issued'").last
      @state_per_order_purchase_revised = @orderOfService.state_per_order_of_services.where("state LIKE 'pre_issued'").last
      @first_state = "Emitido"
      @second_state = "Pre-Emitido"
    end

    if @orderOfService.state == 'revised'
      @state_per_order_purchase_approved = @orderOfService.state_per_order_of_services.where("state LIKE 'revised'").last
      @state_per_order_purchase_revised = @orderOfService.state_per_order_of_services.where("state LIKE 'issued'").last
      @first_state = "Revisado"
      @second_state = "Emitido"
    end

    if @orderOfService.state == 'approved'
      @state_per_order_purchase_approved = @orderOfService.state_per_order_of_services.where("state LIKE 'approved'").last
      @state_per_order_purchase_revised = @orderOfService.state_per_order_of_services.where("state LIKE 'revised'").last
      @first_state = "Aprobado"
      @second_state = "Revisado"
    end

    if @orderOfService.state == 'canceled'
      @state_per_order_purchase_approved = @orderOfService.state_per_order_of_services.where("state LIKE 'canceled'").last
      @state_per_order_purchase_revised = @orderOfService.state_per_order_of_services.where("state LIKE 'canceled'").last
      @first_state = "Cancelado"
      @second_state = "Cancelado"
    end

    prawnto inline: true, :prawn => { :page_size => 'A4', :page_layout => :landscape }

  end

  private
  def order_service_parameters
    params.require(:order_of_service).permit(:date_of_issue, :date_of_service, :method_of_payment_id, :entity_id, :cost_center_id, :money_id, :exchange_of_rate, :user_id, :description, order_of_service_details_attributes: [:id, :order_of_service_id, :article_id, :unit_of_measurement_id, :sector_id, :phase_id, :unit_price, :igv, :amount, :unit_price_igv, :description, :_destroy])
  end
end
