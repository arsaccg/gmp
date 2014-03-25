class Logistics::PurchaseOrdersController < ApplicationController
  def index
    @purchaseOrders = PurchaseOrder.all
    @deliveryOrders = DeliveryOrder.all.where("state LIKE 'approved'")
    render layout: false
  end

  def show
    @purchaseOrder = PurchaseOrder.find(params[:id])
    if params[:state_change] != nil
      @state_change = params[:state_change]
    else
      @purchasePerState = @purchaseOrder.state_per_order_purchases
    end
    @purchaseOrderDetails = @purchaseOrder.purchase_order_details
    render layout: false
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

  def more_items_from_delivery_orders
    @reg_n = Time.now.to_i
    delivery_ids = params[:ids_delivery_order]
    @delivery_orders_detail = CostCenter.find(params[:cost_center_id]).delivery_orders.where("state LIKE 'approved' AND NOT IN (#{delivery_ids})").delivery_order_details
    render(partial: 'modal_more_items_delivery', :layout => false)
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
    @reg_n = Time.now.to_i
    @purchaseOrder = PurchaseOrder.find(params[:id])
    @suppliers = Supplier.all
    @cost_center = CostCenter.all
    @moneys = Money.all
    @methodOfPayments = MethodOfPayment.all
    @action = 'edit'
    render layout: false
  end

  def update
    purchaseOrder = PurchaseOrder.find(params[:id])
    purchaseOrder.update_attributes(purchase_order_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index
  end

  # Este es el cambio de estado
  def destroy
    @purchaseOrder = PurchaseOrder.find_by_id(params[:id])
    @purchaseOrder.cancel
    stateOrderDetail = StatePerOrderPurchase.new
    stateOrderDetail.state = @purchaseOrder.human_state_name
    stateOrderDetail.purchase_order_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    #redirect_to :action => :index
    render :json => @purchaseOrder
  end

  def goissue
    @purchaseOrder = PurchaseOrder.find_by_id(params[:id])
    @purchaseOrder.issue
    stateOrderDetail = StatePerOrderPurchase.new
    stateOrderDetail.state = @purchaseOrder.human_state_name
    stateOrderDetail.purchase_order_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index
  end

  def gorevise
    @purchaseOrder = PurchaseOrder.find_by_id(params[:id])
    @purchaseOrder.revise
    stateOrderDetail = StatePerOrderPurchase.new
    stateOrderDetail.state = @purchaseOrder.human_state_name
    stateOrderDetail.purchase_order_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index
  end

  def goapprove
    @purchaseOrder = PurchaseOrder.find_by_id(params[:id])
    @purchaseOrder.approve
    stateOrderDetail = StatePerOrderPurchase.new
    stateOrderDetail.state = @purchaseOrder.human_state_name
    stateOrderDetail.purchase_order_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index
  end

  def goobserve
    @purchaseOrder = PurchaseOrder.find_by_id(params[:id])
    @purchaseOrder.observe
    stateOrderDetail = StatePerOrderPurchase.new
    stateOrderDetail.state = @purchaseOrder.human_state_name
    stateOrderDetail.purchase_order_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index
  end

  def purchase_order_pdf
    @purchaseOrder = PurchaseOrder.find(params[:id])
    @purchaseOrderDetails = @purchaseOrder.purchase_order_details
    aux = 0
    @deliveryOrders = Array.new
    @purchaseOrder.purchase_order_details.each do |pod|
      current_id = pod.delivery_order_detail.delivery_order.id
      if aux != current_id
        aux = current_id
        @deliveryOrders << current_id.to_s.rjust(5, '0')
      end
    end

    # Numerics/Text values for footer
    @total = 0
    @igv = 0
    @purchaseOrderDetails.each do |pod|
      @total += pod.delivery_order_detail.amount*pod.unit_price
    end
    @igv = @total*0.18
    @total_neto = @total - @igv

    if @purchaseOrder.state == 'pre_issued'
      @state_per_order_purchase_approved = @purchaseOrder.state_per_order_purchases.where("state LIKE 'pre_issued'").last
      @state_per_order_purchase_revised = @purchaseOrder.state_per_order_purchases.where("state LIKE 'pre_issued'").last

      if @state_per_order_purchase_approved == nil && @state_per_order_purchase_revised == nil
        @state_per_order_purchase_approved = @purchaseOrder
        @state_per_order_purchase_revised = @purchaseOrder
      end

      @first_state = "Pre-Emitido"
      @second_state = "Pre-Emitido"
    end

    if @purchaseOrder.state == 'issued'
      @state_per_order_purchase_approved = @purchaseOrder.state_per_order_purchases.where("state LIKE 'issued'").last
      @state_per_order_purchase_revised = @purchaseOrder.state_per_order_purchases.where("state LIKE 'pre_issued'").last
      @first_state = "Emitido"
      @second_state = "Pre-Emitido"
    end

    if @purchaseOrder.state == 'revised'
      @state_per_order_purchase_approved = @purchaseOrder.state_per_order_purchases.where("state LIKE 'revised'").last
      @state_per_order_purchase_revised = @purchaseOrder.state_per_order_purchases.where("state LIKE 'issued'").last
      @first_state = "Revisado"
      @second_state = "Emitido"
    end

    if @purchaseOrder.state == 'approved'
      @state_per_order_purchase_approved = @purchaseOrder.state_per_order_purchases.where("state LIKE 'approved'").last
      @state_per_order_purchase_revised = @purchaseOrder.state_per_order_purchases.where("state LIKE 'revised'").last
      @first_state = "Aprobado"
      @second_state = "Revisado"
    end

    if @purchaseOrder.state == 'canceled'
      @state_per_order_purchase_approved = @purchaseOrder.state_per_order_purchases.where("state LIKE 'canceled'").last
      @state_per_order_purchase_revised = @purchaseOrder.state_per_order_purchases.where("state LIKE 'canceled'").last
      @first_state = "Cancelado"
      @second_state = "Cancelado"
    end

    prawnto inline: true, :prawn => { :page_size => 'A4', :page_layout => :landscape }

  end

  private
  def purchase_order_parameters
    params.require(:purchase_order).permit(:exchange_of_rate, :date_of_issue, :expiration_date, :delivery_date, :retention, :money_id, :method_of_payment_id, :supplier_id, :cost_center_id, :state, :description, purchase_order_details_attributes: [:id, :puchase_order_id, :delivery_order_detail_id, :unit_price, :igv, :unit_price_igv, :description])
  end
end
