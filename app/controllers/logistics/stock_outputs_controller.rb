class Logistics::StockOutputsController < ApplicationController
  def index
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
    @head = StockInput.new
    @responsibles = Entity.joins(:type_entities).where("type_entities.preffix" => "P")
    @periods = LinkTime.group(:year, :month)
    @warehouses = Warehouse.all
    @articles = Article.all
    @formats = Format.joins{format_per_documents.document}.where{(documents.preffix.eq "OWH")}
    render layout: false
  end

  def edit
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

  def show_purchase_order_item_field
    supplier = Entity.find(params[:id])
    @tableItems = supplier.purchase_orders.where("state LIKE 'approved'")
    render(partial: 'table_items_order', :layout => false)
  end

  def add_items_from_pod
    @reg_n = Time.now.to_i
    @arrItems = Array.new
    params[:ids_items].each do |ido|
      @arrItems << PurchaseOrderDetail.find(ido)
    end
    render(partial: 'table_items_detail', :layout => false)
  end

  def more_items_from_pod
    @reg_n = Time.now.to_i
    ids_items = params[:ids_items].join(",")
    @tableItems = Array.new
    PurchaseOrder.where("state LIKE 'approved'").each do |x|
      x.purchase_order_details.where("received IS NULL").where("id NOT IN (#{ids_items})").each do |y|
        @tableItems << y
      end
    end
    render(partial: 'modal_more_items', :layout => false)
  end

  def add_stock_input_item_field
    @reg_n = Time.now.to_i
    data_article_unit = params[:article_id].split('-')
    @article = Article.find(data_article_unit[0])
    @amount = params[:amount].to_i
    
    render(partial: 'add_item', :layout => false)
  end

  private
  def stock_input_parameters
    params.require(:stock_input).permit(:supplier_id, :warehouse_id, :period, :format_id, :document, :issue_date, :description, :input, stock_input_details_attributes: [:id, :stock_input_id, :article_id, :amount, :equipment_id])
  end
end