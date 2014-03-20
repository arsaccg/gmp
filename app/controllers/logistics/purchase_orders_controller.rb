class Logistics::PurchaseOrdersController < ApplicationController
  def index
    @purchaseOrders = PurchaseOrder.all
    @deliveryOrders = DeliveryOrder.all.where("state LIKE 'approved'")
    render layout: false
  end

  def show
  end

  def new
    @purchaseOrder = PurchaseOrder.new
    @suppliers = Supplier.all
    @cost_center = CostCenter.all
    @moneys = Money.all
    @methodOfPayments = MethodOfPayment.all
    render layout: false
  end

  def show_delivery_order_item_field
    cost_center = CostCenter.find(params[:id])
    @deliveryOrders = cost_center.delivery_orders.where("state LIKE 'approved'")
    render(partial: 'table_items_order', :layout => false)
  end

  def add_items_from_delivery_orders
    @reg_n = Time.now.to_i
    @delivery_orders_detail = Array.new
    params[:ids_delivery_order].each do |ido|
      @delivery_orders_detail << DeliveryOrderDetail.find(ido)
    end
    render(partial: 'table_order_delivery_items', :layout => false)
  end

  def create
    @purchaseOrder = PurchaseOrder.new(purchase_order_parameters)
    @purchaseOrder.state = 'pre_issued'
    @purchaseOrder.user_id = current_user.id
    if @purchaseOrder.save
      flash[:notice] = "Se ha creado correctamente la nueva orden de compra."
      redirect_to :action => :index
    else
      @purchaseOrder.errors.messages.each do |attribute, error|
        puts attribute
        puts error
      end
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => :index
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def purchase_order_pdf
    
  end

  private
  def purchase_order_parameters
    params.require(:purchase_order).permit(:exchange_of_rate, :date_of_issue, :expiration_date, :delivery_date, :retention, :money_id, :method_of_payment_id, :supplier_id, :cost_center_id, :state, :description, purchase_order_details_attributes: [:id, :puchase_order_id, :delivery_order_detail_id, :unit_price, :igv, :unit_price_igv, :description])
  end
end
