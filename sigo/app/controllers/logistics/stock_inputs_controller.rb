class Logistics::StockInputsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    #@input = params[:input]
    @company = get_company_cost_center('company')
    @cost_centers = get_company_cost_center('cost_center')
    #@head = StockInput.where("input = 1")
    @purchaseOrders = PurchaseOrder.get_approved_by_company(@company)

    # 20150223 Ajuste Masivo (INI) : Update Masivo del Period & Year, según issue_date
    #@StockAll = StockInput.all
    #@StockAll.each do |x|
    #  @Stock = StockInput.find(x.id)
    #  @Stock.update_attributes(:period => x.issue_date.strftime("%Y%m"), :year => x.issue_date.strftime("%Y"))
    #end
    # 20150223 Ajuste Masivo (FIN)

    render layout: false
  end

  def create
    @head = StockInput.new(stock_input_parameters)
    #@head.issue_date = stock_input_parameters['issue_date']
    @head.period = @head.issue_date.strftime("%Y%m")
    @head.year = @head.issue_date.strftime("%Y")
    #@head.year = @head.period.to_s[0,4]
    @head.user_inserts_id = current_user.id
    #@head.stock_input_details.user_inserts_id = current_user.id
    if @head.save
      # Verified If All Received
      @head.stock_input_details.each do |x|
        @pod = PurchaseOrderDetail.find(x.purchase_order_detail.id)
        sum = 0
        total = StockInputDetail.where("purchase_order_detail_id = ?",@pod.id)
        total.each do |tt|
          sum+=tt.amount.to_f
        end
        if @pod.amount.to_f == sum.to_f
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

    @period = head.issue_date.strftime("%Y%m")
    @year = head.issue_date.strftime("%Y")
    head.update_attributes(:period => @period, :year => @year)

    head.stock_input_details.each do |x|
      @pod = PurchaseOrderDetail.find(x.purchase_order_detail.id)
      sum = 0
      total = StockInputDetail.where("purchase_order_detail_id = ?",@pod.id)
      total.each do |tt|
        sum+=tt.amount.to_f
      end
      if @pod.amount.to_f == sum.to_f
        @pod.update_attributes(:received => 1)
      end
      if @pod.amount.to_f != sum.to_f
        @pod.update_attributes(:received => nil)
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
        sum+=tt.amount.to_f
      end
      if @pod.amount.to_f > sum.to_f
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
    PurchaseOrder.select(:id).select(:code).select(:description).joins(:purchase_order_details).where("purchase_order_details.received IS NULL AND purchase_order_details.purchase_order_id = purchase_orders.id AND entity_id = ? AND state LIKE 'approved' AND cost_center_id = ?", supplier_id, get_company_cost_center('cost_center')).each do |purchaseOrder|
      if purchaseOrder.purchase_order_details.where("received IS NULL").count > 0 
        str_option += "<option value=" + purchaseOrder.id.to_s + ">" + purchaseOrder.code.to_s.rjust(5, '0') + ' - ' + purchaseOrder.description.to_s + "</option>"
      end
    end
    render :json => str_option
  end

  def show_stock_inputs
    display_length = params[:iDisplayLength]
    pager_number = params[:iDisplayStart]
    keyword = params[:sSearch]
    array = Array.new
    cost_center = get_company_cost_center('cost_center')

    outputs = StockInput.get_input(cost_center, display_length, pager_number, keyword)
    # si.id, CONCAT(wa.name, ' - ', wa.location), si.issue_date, si.document, w.id , fo.name
    outputs.each do |output|
      array << [
        output[1],
        output[2].strftime("%d/%m/%Y").to_s,
        output[3],
        output[4],
        output[5],
        "<a class='btn btn-info btn-xs' onclick=javascript:load_url_ajax('/logistics/stock_inputs/" + output[0].to_s + "','content',null,null,'GET')> Ver información </a> " + "<a class='btn btn-warning btn-xs' onclick=javascript:load_url_ajax('/logistics/stock_inputs/" + output[0].to_s + "/edit','content',null,null,'GET')> Editar </a> " + "<a class='btn btn-danger btn-xs' data-onclick=javascript:delete_to_url('/logistics/stock_inputs/" + output[0].to_s + "','content','/logistics/stock_inputs') data-placement='left' data-popout='true' data-singleton='true' data-title='Esta seguro de eliminar el item?' data-toggle='confirmation' data-original-title='' title=''> Eliminar </a>"+ "<a style='margin-left: 5px;' class='btn btn-pdf btn-xs' data-original-title='Ver PDF' data-placement='top' href='/logistics/stock_inputs/" + output[0].to_s + "/report_pdf.pdf' rel='tooltip' target='_blank'><i class='fa fa-file'></i></a>"
      ]
    end
    render json: { :aaData => array }
  end

  def report_pdf
    @input = StockInput.find(params[:id])
    @now = Time.now.strftime("%d/%m/%Y - %H:%M")
    @company = Company.find(@input.company_id)
    @orders = Array.new
    @input.stock_input_details.map(&:purchase_order_detail_id).each do |si|
      @orders << PurchaseOrderDetail.find(si).purchase_order.code
    end
    @orders = @orders.join(', ')
    @cost_center = CostCenter.find(@input.cost_center_id)
    @cost_center = @cost_center.code.to_s + " - " + @cost_center.name
    ent = Entity.find(@input.supplier_id) rescue nil 
    @responsable = ent.name + " - " + ent.ruc rescue "-"
    @input_detail = @input.stock_input_details
    prawnto inline: true, :prawn => { :page_size => 'A4', :page_layout => :landscape }
  end  

  private
  def stock_input_parameters
    params.require(:stock_input).permit(:supplier_id, :lock_version, :warehouse_id, :period, :format_id, :series, :document, :issue_date, :description, :input, :company_id, :cost_center_id, stock_input_details_attributes: [:id, :stock_input_id, :purchase_order_detail_id, :article_id, :amount, :_destroy])
  end
end
