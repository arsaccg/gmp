class Logistics::OrderOfServicesController < ApplicationController
  def index
    @article = Article.first
    @phase = Phase.first
    @sector = Sector.first
    @company = params[:company_id]
    @costcenters = CostCenter.where("company_id = #{@company}")
    render layout: false
  end

  def show
  end

  def new
    @company = params[:company_id]
    # Set default value
    @igv = 0.18+1
    @cost_center = CostCenter.find(params[:cost_center_id])
    @cost_center_id = @cost_center.id
    @orderOfService = OrderOfService.new
    @articles = Article.all
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
    @reg_n = Time.now.to_i
    data_article_unit = params[:article_id].split('-')
    @article = Article.find(data_article_unit[0])
    @sectors = Sector.all
    @phases = Phase.where("category LIKE 'phase'")
    @amount = params[:amount].to_f
    @centerOfAttention = CenterOfAttention.all
    @code_article, @name_article, @id_article = @article.code, @article.name, @article.id
    @unitOfMeasurement = UnitOfMeasurement.find(data_article_unit[1]).symbol
    @unitOfMeasurementId = data_article_unit[1]
    
    render(partial: 'order_service_items', :layout => false)
  end

  def show_rows_orders_service
    @orderOfServices = Array.new
    @company = params[:company_id]
    Company.find(@company).cost_centers.find(params[:cost_center_id]).order_of_services.each do |order_service|
      @orderOfServices << order_service
    end
    render(partial: 'rows_order_of_services', :layout => false)
  end

  def edit
    @company = params[:company_id]
    @reg_n = Time.now.to_i
    # Set default value
    @igv = 0.18+1
    @orderOfService = OrderOfService.find(params[:id])
    @articles = Article.all
    @sectors = Sector.all
    @phases = Phase.where("category LIKE 'phase'")
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

  def destroy

  end

  # DO DELETE row
  def delete
    @orderOfService = OrderOfService.destroy(params[:id])
    @orderOfService.order_of_service_details.each do |oos|
      OrderOfServiceDetail.destroy(oos.id)
    end
    render :json => @orderOfService
  end

  private
  def order_service_parameters
    params.require(:order_of_service).permit(:date_of_issue, :date_of_service, :method_of_payment_id, :entity_id, :cost_center_id, :money_id, :exchange_of_rate, :user_id, :description, order_of_service_details_attributes: [:id, :order_of_service_id, :article_id, :unit_of_measurement_id, :sector_id, :phase_id, :unit_price, :igv, :amount, :unit_price_igv, :description, :_destroy])
  end
end
