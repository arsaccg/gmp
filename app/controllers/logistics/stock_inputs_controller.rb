class Logistics::StockInputsController < ApplicationController
  def index
    @head = StockInput.all
    @purchaseOrders = PurchaseOrder.all.where("state LIKE 'approved'")
    render layout: false
  end

  def create
    @head = StockInput.new(stock_input_parameters)
    @head.user_inserts_id = current_user.id
    if @head.save
      # Verified If All Received
      @head.stock_input_details.each do |x|
        @pod = PurchaseOrderDetail.find(x.purchase_order_detail.id)
        if @pod.amount <= PurchaseOrderDetail.get_total_received(x.purchase_order_detail.id)
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
    @head = StockInput.new
    @suppliers = Entity.joins(:type_entities).where("type_entities.preffix" => "P")
    @periods = LinkTime.group(:year, :month)
    @warehouses = Warehouse.all
    @formats = Format.all#.joins(:documents).where("documents.id" => 44)
    render layout: false
  end

  def edit
  end

  def update
    head = StockInput.find(params[:id])
    head.update_attributes(stock_input_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index
  end

  def destroy
  end

  def show_purchase_order_item_field
    supplier = Entity.find(params[:id])
    @tableItems = supplier.purchase_orders.where("state LIKE 'approved'")
    render(partial: 'table_items_order', :layout => false)
  end

  def add_items_from_purchase_order
    @reg_n = Time.now.to_i
    @arrItems = Array.new
    params[:ids_items].each do |ido|
      @arrItems << PurchaseOrderDetail.find(ido)
    end
    render(partial: 'table_items_detail', :layout => false)
  end

  private
  def stock_input_parameters
    params.require(:stock_input).permit(:supplier_id, :warehouse_id, :period, :format_id, :series, :document, :issue_date, :description, stock_input_details_attributes: [:id, :stock_input_id, :purchase_order_detail_id, :amount])
  end
end
