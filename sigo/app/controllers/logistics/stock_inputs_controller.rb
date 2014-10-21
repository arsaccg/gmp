class Logistics::StockInputsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    #@input = params[:input]
    @company = get_company_cost_center('company')
    @cost_centers = get_company_cost_center('cost_center')
    @head = StockInput.where("input = 1")
    @purchaseOrders = PurchaseOrder.get_approved_by_company(@company)
    render layout: false
  end

  def create
    @head = StockInput.new(stock_input_parameters)
    #@head.issue_date = stock_input_parameters['issue_date']
    @head.year = @head.period.to_s[0,4]
    @head.user_inserts_id = current_user.id
    #@head.stock_input_details.user_inserts_id = current_user.id
    if @head.save
      # Verified If All Received
      @head.stock_input_details.each do |x|
        @pod = PurchaseOrderDetail.find(x.purchase_order_detail.id)
        sum = 0
        total = StockInputDetail.where("purchase_order_detail_id = ?",@pod.id)
        total.each do |tt|
          sum+=tt.amount.to_i
        end
        if @pod.amount == sum
          @pod.update_attributes(:received => 1)
        end
      end
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
    @cost_center = get_company_cost_center('cost_center')
    @head = StockInput.new
    #@periods = LinkTime.group(:year, :month)
    @warehouses = Warehouse.where(company_id: "#{@company}")
    @formats = Format.joins{format_per_documents.document}.where{(documents.preffix.eq "IWH")}
    render layout: false
  end

  def display_supplier
    word = params[:q]
    article_hash = Array.new
    articles = StockInput.getSupplier(word, get_company_cost_center('cost_center'))
    articles.each do |art|
      article_hash << {'id' => art[0].to_s, 'name' => art[1]}
    end
    render json: {:articles => article_hash}
  end

  def show
    @company = get_company_cost_center('company')
    @head = StockInput.find(params[:id])
    @suppliers = Entity.joins(:type_entities).where("type_entities.preffix" => "P")
    @periods = LinkTime.group(:year, :month)
    @warehouses = Warehouse.where(company_id: "#{@company}")
    @formats = Format.joins{format_per_documents.document}.where{(documents.preffix.eq "IWH")}
    @reg_n = Time.now.to_i
    @arrItems = Array.new
    @head.stock_input_details.each do |sid|
      @arrItems << StockInputDetail.find(sid)
    end
    render layout: false
  end

  def edit
    @company = get_company_cost_center('company')
    @head = StockInput.find(params[:id])
    @suppliers = Entity.joins(:type_entities).where("type_entities.preffix" => "P")
    @periods = LinkTime.group(:year, :month)
    @warehouses = Warehouse.where(company_id: "#{@company}")
    @formats = Format.joins{format_per_documents.document}.where{(documents.preffix.eq "IWH")}
    @reg_n = Time.now.to_i
    @arrItems = @head.stock_input_details
    render layout: false
  end

  def update
    head = StockInput.find(params[:id])
    ids1 = Array.new
    ids2 = Array.new
    head.stock_input_details.each do |x|
      ids1 << x.purchase_order_detail_id
    end
    head.update_attributes(stock_input_parameters)
    head.stock_input_details.each do |x|
      @pod = PurchaseOrderDetail.find(x.purchase_order_detail.id)
      sum = 0
      total = StockInputDetail.where("purchase_order_detail_id = ?",@pod.id)
      total.each do |tt|
        sum+=tt.amount.to_i
      end
      if @pod.amount == sum
        @pod.update_attributes(:received => 1)
      end
    end
    head.stock_input_details.each do |x|
      ids2 << x.purchase_order_detail_id
    end
    ids1.each do |x|
      if !ids2.include?(x)
        PurchaseOrderDetail.find(x).update_attributes(:received => nil)
      end
    end
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index
  rescue ActiveRecord::StaleObjectError
    head.reload
    flash[:error] = "Alguien más ha modificado los datos en este instante. Intente Nuevamente."
    redirect_to :action => :index
  end

  def destroy
    sinput = StockInput.find(params[:id])
    sinput.stock_input_details.each do |sin|
      @pod = PurchaseOrderDetail.find(sin.purchase_order_detail.id)
      sinputdetail = StockInputDetail.destroy(sin.id)
      sum = 0
      total = StockInputDetail.where("purchase_order_detail_id = ?",@pod.id)
      total.each do |tt|
        sum+=tt.amount.to_i
      end
      if @pod.amount > sum
          @pod.update_attributes(:received => nil)
      end
    end
    item = StockInput.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => item
  end

  def show_rows_stock_inputs
    @head = Array.new
    @company = get_company_cost_center('company')
    StockInput.where(company_id: @company).where(cost_center_id: params[:cost_center_id]).where(input: 1).each do |x|
      @head << x
    end
    render(partial: 'rows_stock_inputs', :layout => false)
  end

  def show_purchase_order_item_field
    @company = get_company_cost_center('cost_center')
    #@tableItems = PurchaseOrder.get_approved_by_company_and_supplier(@company, params[:id], params[:order])
    if params[:order]==""
      @tableItems = PurchaseOrder.where("entity_id = "+params[:id].to_s+" AND cost_center_id = "+@company.to_s)
    else
      order = params[:order].to_a.join(',')
      @tableItems = PurchaseOrder.where("entity_id = "+params[:id].to_s+" AND cost_center_id = "+@company.to_s+" AND id IN ("+order+")")
    end
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
    @company = get_company_cost_center('company')
    @reg_n = Time.now.to_i
    @ids_items = 0
    if (params[:ids_items] != nil)
      @ids_items = params[:ids_items].join(",")
    end
    @tableItems = Array.new
    #PurchaseOrder.where("state LIKE 'approved'").each do |x|
    #  x.purchase_order_details.where("received IS NULL").where("id NOT IN (#{ids_items})").each do |y|
    #    @tableItems << y
    #  end
    #end
    logger.info "@ids_items:" + @ids_items.to_s
    PurchaseOrderDetail.get_approved_more_items(@company, params[:supplier_id], @ids_items).each do |y|
      @tableItems << y
    end
    render(partial: 'modal_more_items', :layout => false)
  end

  def show_purchase_orders
    str_option = ""
    supplier_id = params[:id]
    PurchaseOrder.select(:id).select(:description).where("entity_id = ? AND state LIKE 'approved'", supplier_id).each do |purchaseOrder|
      if purchaseOrder.purchase_order_details.where("received IS NULL").count > 0 
        str_option += "<option value=" + purchaseOrder.id.to_s + ">" + purchaseOrder.id.to_s.rjust(5, '0') + ' - ' + purchaseOrder.description.to_s + "</option>"
      end
    end
    render :json => str_option
  end

  private
  def stock_input_parameters
    params.require(:stock_input).permit(:supplier_id, :lock_version, :warehouse_id, :period, :format_id, :series, :document, :issue_date, :description, :input, :company_id, :cost_center_id, stock_input_details_attributes: [:id, :stock_input_id, :purchase_order_detail_id, :article_id, :amount, :_destroy])
  end
end
