class Logistics::OrderOfServicesController < ApplicationController
  def index
    @company = params[:company_id]
    @costcenters = CostCenter.where("company_id = #{@company}")
    render layout: false
  end

  def show
  end

  def new
    @company = params[:company_id]
    @cost_center = CostCenter.where("company_id = #{@company}")
    @orderOfService = OrderOfService.new
    @articles = Article.all
    @methodOfPayments = MethodOfPayment.all
    render layout: false
  end

  def create
    redirect_to :action => :index, company_id: params[:company_id]
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

  def edit
    @company = params[:company_id]
    @orderOfService = OrderOfService.find(params[:id])
    @articles = Article.all
    @sectors = Sector.all
    @phases = Phase.where("category LIKE 'phase'")
    @costcenters = Company.find(@company).cost_centers
    @action = 'edit'
    render layout: false
  end

  def update
    redirect_to :action => :index, company_id: params[:company_id]
  end

  def destroy

  end

  private
  def order_service_parameters
    params.require(:order_of_service).permit(:date_of_issue, :method_of_payment_id, :entity_id, :cost_center_id, :user_id, :description, order_of_service_details_attributes: [:id, :order_of_service_id, :article_id, :unit_of_measurement_id, :sector_id, :phase_id, :unit_price, :igv, :amount, :unit_price_igv, :description, :_destroy])
  end
end
