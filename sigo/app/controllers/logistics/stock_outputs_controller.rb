class Logistics::StockOutputsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    @company = get_company_cost_center('company')
    @cost_centers = get_company_cost_center('cost_center')
    @head = StockInput.where("input = 0")
    @purchaseOrders = PurchaseOrder.all.where("state LIKE 'approved'")
    render layout: false
  end

  def create
    @head = StockInput.new(stock_input_parameters)
    @head.year = @head.period.to_s[0,4]
    @head.user_inserts_id = current_user.id
    if @head.save
      flash[:notice] = "Se ha creado correctamente el registro."
      redirect_to :action => :index
    else
      @head.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      render :new, layout: false
    end
  end

  def new
    @company = get_company_cost_center('company')
    @head = StockInput.new
    @cost_center = get_company_cost_center('cost_center')
    @responsibles = Entity.joins(:type_entities).where("type_entities.preffix" => "T")
    @periods = LinkTime.group(:year, :month)
    @warehouses = Warehouse.where(company_id: "#{@company}")
    @articles = Article.getSpecificArticlesforStockOutputs(@cost_center)
    @formats = Format.joins{format_per_documents.document}.where{(documents.preffix.eq "OWH")}
    @working_groups = WorkingGroup.all
    render layout: false
  end

  def edit
    @company = get_company_cost_center('company')
    @head = StockInput.find(params[:id])
    @responsibles = Entity.joins(:type_entities).where("type_entities.preffix" => "T")
    @periods = LinkTime.group(:year, :month)
    @warehouses = Warehouse.where(company_id: "#{@company}").where(cost_center_id: "#{@head.cost_center_id}")
    @articles = Article.all
    @formats = Format.joins{format_per_documents.document}.where{(documents.preffix.eq "OWH")}
    @sectors = Sector.all
    @phases = Phase.where("category LIKE 'phase'")
    @working_groups = WorkingGroup.all
    @reg_n = Time.now.to_i
    @arrItems = Array.new
    @head.stock_input_details.each do |sid|
      @arrItems << StockInputDetail.find(sid)
    end
    render layout: false
  end

  def update
    head = StockInput.find(params[:id])
    head.year = head.period.to_s[0,4]
    head.update_attributes(stock_input_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index
  end

  def destroy
    flash[:error] = nil
    item = StockInput.find(params[:id])
    item.update_attributes({status: "D", user_updates_id: params[:current_user_id]})
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => item
  end

  def show_rows_stock_inputs
    @head = Array.new
    @company = get_company_cost_center('company')
    StockInput.where(company_id: @company).where(cost_center_id: params[:cost_center_id]).where(input: 0).each do |x|
      @head << x
    end
    render(partial: 'rows_stock_inputs', :layout => false)
  end

  def add_stock_input_item_field
    @reg_n = Time.now.to_i
    data_article_unit = params[:article_id].split('-')
    @company_id = params[:company_id]
    @cost_center = get_company_cost_center('cost_center')
    @article = Article.find(data_article_unit[0])
    @amount = params[:amount].to_i
    @sectors = Sector.all
    @phases = Phase.getSpecificPhases(@cost_center)
    
    render(partial: 'add_item', :layout => false)
  end

  private
  def stock_input_parameters
    params.require(:stock_input).permit(:responsible_id, :warehouse_id, :period, :format_id, :document, :issue_date, :description, :input, :working_group_id, :company_id, :cost_center_id, stock_input_details_attributes: [:id, :stock_input_id, :article_id, :amount, :sector_id, :phase_id, :equipment_id, :_destroy])
  end
end