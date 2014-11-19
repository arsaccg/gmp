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
    @head.user_inserts_id = current_user.id
    @head.series = 0
    @head.supplier_id = 0
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
    @responsibles = Worker.where("cost_center_id = ?",@cost_center)
    # @periods = LinkTime.group(:year, :month)
    @warehouses = Warehouse.where(company_id: "#{@company}")
    @formats = Format.joins{format_per_documents.document}.where{(documents.preffix.eq "OWH")}
    @working_groups = WorkingGroup.all
    @reg_n = Time.now.to_i
    render layout: false
  end

  def partial_select_per_warehouse
    @warehouse = params[:warehouse_id]
    render(:partial => 'partial_select_per_warehouse', layout: false)
  end

  def display_articles_per_warehouse
    word = params[:q]
    warehouse = params[:warehouse]
    idsn = params[:idsn]
    if idsn == ""
      idsn = 0
    else
      idsn=idsn.split('-')
      idsn=idsn.join(',')
    end
    article_hash = Array.new
    articles = Article.getSpecificArticlesPerWarehouse(warehouse,word, idsn)
    articles.each do |art|
      rest = Article.getSpecificArticlesforStockOutputs4(warehouse,art[0].to_i)
      if rest.count>0
        rest = rest.first.at(0).to_i
      else
        rest = 0
      end
      if (art[4]-rest)>0
        article_hash << {'id' => art[0].to_s, 'name' => art[1] + ' - ' + art[2] + ' - ' + art[3]}
      end        
    end
    render json: {:articles => article_hash}
  end

  def partial_table_per_warehouse
    article_warehouse = params[:data]
    @warehouse = params[:warehouse]
    @article=Array.new
    article = Article.getSpecificArticlePerConsult(@warehouse, article_warehouse)
    article.each do |art|
      rest = Article.getSpecificArticlesforStockOutputs4(@warehouse,art[0].to_i)
      if rest.count>0
        rest = rest.first.at(0).to_i
      else
        rest = 0
      end
      if (art[4]-rest)>0
      end    
      @article << [art[0], art[1], art[2], art[3], art[4], art[4]-rest]
    end
    render(:partial => 'partial_table_per_warehouse', layout: false)
  end

  def show
    @company = get_company_cost_center('company')
    @cost_center = get_company_cost_center('cost_center')
    @head = StockInput.find(params[:id])
    @responsibles = Entity.joins(:type_entities).where("type_entities.preffix" => "T")
    @periods = LinkTime.group(:year, :month)
    @warehouses = Warehouse.where(company_id: "#{@company}").where(cost_center_id: "#{@head.cost_center_id}")
    @articles = Article.getSpecificArticlesforStockOutputs(@cost_center)
    @formats = Format.joins{format_per_documents.document}.where{(documents.preffix.eq "OWH")}
    @sectors = Sector.all
    @phases = Phase.getSpecificPhases(@cost_center)
    @working_groups = WorkingGroup.all
    @reg_n = Time.now.to_i
    @arrItems = Array.new
    @head.stock_input_details.each do |sid|
      @arrItems << StockInputDetail.find(sid)
    end
    render layout: false
  end

  def edit
    @company = get_company_cost_center('company')
    @cost_center = get_company_cost_center('cost_center')
    @head = StockInput.find(params[:id])
    @responsibles = Entity.joins(:type_entities).where("type_entities.preffix" => "T")
    # @periods = LinkTime.group(:year, :month)
    @warehouses = Warehouse.where(company_id: "#{@company}").where(cost_center_id: "#{@head.cost_center_id}")
    @articles = Article.getSpecificArticlesforStockOutputs(@cost_center)
    @formats = Format.joins{format_per_documents.document}.where{(documents.preffix.eq "OWH")}
    @sectors = Sector.all
    @phases = Phase.getSpecificPhases(@cost_center)
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
    @sectors = Sector.where("code LIKE '__' ")
    @phases = Phase.getSpecificPhases(@cost_center)
    
    render(partial: 'add_item', :layout => false)
  end

  def add_items_from_pod
    puts '---------------'
    puts params[:warehouse_id2]
    puts '---------------'
    @reg_n = Time.now.to_i
    @array1 = Array.new
    @array2 = Array.new
    @arrItems = Array.new
    ids_items = params[:ids_items]
    ids_items = ids_items.join(',')
    @warehouse_id = params[:warehouse_id2]
    @sectors = Sector.where("code LIKE '__'")
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center'))
    @arrItems = Article.getSpecificArticlesforStockOutputs2(@warehouse_id,ids_items)
    @arrItems.each do |ai|
      @array1 << ai
    end
    render(partial: 'table_items_detail', :layout => false)
  end

  private
  def stock_input_parameters
    params.require(:stock_input).permit(:responsible_id, :warehouse_id, :lock_version, :period, :format_id, :document, :issue_date, :description, :input, :working_group_id, :company_id, :cost_center_id, stock_input_details_attributes: [:id, :stock_input_id, :article_id, :amount, :sector_id, :phase_id, :equipment_id, :lock_version, :_destroy])
  end
end