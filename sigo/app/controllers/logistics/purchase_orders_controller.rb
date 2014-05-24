class Logistics::PurchaseOrdersController < ApplicationController
  def index
    @company = params[:company_id]
    @company = get_company_cost_center('company')
    cost_center = get_company_cost_center('cost_center')
    @purchaseOrders = PurchaseOrder.where('cost_center_id = ?', cost_center)
    @deliveryOrders = DeliveryOrder.where("cost_center_id = ? AND state LIKE ?", @cost_center,'approved')
    render layout: false
  end

  def show
    @company = params[:company_id]
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
    @company = get_company_cost_center('company')
    @cost_center = get_company_cost_center('cost_center')
    @purchaseOrder = PurchaseOrder.new
    #Calcular IGV
    FinancialVariable.where("name LIKE '%IGV%'").each do |val|
      @igv= val.value.to_f+1
    end
    TypeEntity.where("id = 1").each do |tent|
      @suppliers = tent.entities
    end
    @deliveryOrders = DeliveryOrder.where("cost_center_id = ? AND state LIKE ?", @cost_center,'approved')
    @moneys = Money.all
    @methodOfPayments = MethodOfPayment.all
    render layout: false
  end

  def edit
    @company = params[:company_id]
    @reg_n = Time.now.to_i
    @purchaseOrder = PurchaseOrder.find(params[:id])
    #Calcular IGV
    FinancialVariable.where("name LIKE '%IGV%'").each do |val|
      @igv= val.value.to_f+1
    end
    TypeEntity.where("id = 1").each do |tent|
      @suppliers = tent.entities
    end
    @cost_center = CostCenter.all
    @moneys = Money.all
    @methodOfPayments = MethodOfPayment.all
    @action = 'edit'
    render layout: false
  end

  def add_items_from_delivery_orders
    @reg_n = Time.now.to_i
    @delivery_orders_detail = Array.new
    params[:ids_delivery_order].each do |ido|
      @delivery_order_detail = DeliveryOrderDetail.find(ido)
      total = @delivery_order_detail.amount
      sum = 0
      @delivery_order_detail.purchase_order_details.each do |pod|
        if pod.amount == nil
          sum += 0
        else
          sum += pod.amount
        end
      end
      @delivery_order_detail.amount = total - sum
      @delivery_orders_detail << @delivery_order_detail
    end
    render(partial: 'table_order_delivery_items', :layout => false)
  end

  def more_items_from_delivery_orders
    @reg_n = Time.now.to_i
    delivery_ids = params[:ids_delivery_order].join(",")
    @delivery_orders_detail = Array.new
    @cost_center = CostCenter.find(params[:cost_center_id])
    @cost_center.delivery_orders.where("state LIKE 'approved'").each do |deo|
      deo.delivery_order_details.where("id NOT IN (#{delivery_ids})").each do |dodw|
        @delivery_orders_detail << dodw
      end
    end
    render(partial: 'modal_more_items_delivery', :layout => false)
  end

  def create
    @purchaseOrder = PurchaseOrder.new(purchase_order_parameters)
    @purchaseOrder.state = 'pre_issued'
    @purchaseOrder.user_id = current_user.id
    if @purchaseOrder.save

      @purchaseOrder.purchase_order_details.each do |pod|
        dod_id = pod.delivery_order_detail_id
        sql_purchase_order_partial_amount = PurchaseOrder.get_total_amount_items_requested_by_purchase_order(dod_id)
        sql_delivery_order_total_amount = PurchaseOrder.get_total_amount_per_delivery_order(dod_id)

        if sql_purchase_order_partial_amount.first == sql_delivery_order_total_amount.first
          @deliveryOrderDetail = DeliveryOrderDetail.find(dod_id)
          @deliveryOrderDetail.update_attributes(:requested => 1)
        end
      end

      flash[:notice] = "Se ha creado correctamente la nueva orden de compra."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      @purchaseOrder.errors.messages.each do |attribute, error|
        puts attribute
        puts error
      end
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def update
    purchaseOrder = PurchaseOrder.find(params[:id])
    purchaseOrder.update_attributes(purchase_order_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index, company_id: params[:company_id]
  end

  # DO DELETE row
  def delete
    @purchaseOrder = PurchaseOrder.destroy(params[:id])
    @purchaseOrder.purchase_order_details.each do |pod|
      PurchaseOrderDetail.destroy(pod.id)
    end
    render :json => @purchaseOrder
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
    #redirect_to :action => :index, company_id: params[:company_id]
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
    redirect_to :action => :index, company_id: params[:company_id]
  end

  def gorevise
    @purchaseOrder = PurchaseOrder.find_by_id(params[:id])
    @purchaseOrder.revise
    stateOrderDetail = StatePerOrderPurchase.new
    stateOrderDetail.state = @purchaseOrder.human_state_name
    stateOrderDetail.purchase_order_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index, company_id: params[:company_id]
  end

  def goapprove
    @purchaseOrder = PurchaseOrder.find_by_id(params[:id])
    @purchaseOrder.approve
    stateOrderDetail = StatePerOrderPurchase.new
    stateOrderDetail.state = @purchaseOrder.human_state_name
    stateOrderDetail.purchase_order_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index, company_id: params[:company_id]
  end

  def goobserve
    @purchaseOrder = PurchaseOrder.find_by_id(params[:id])
    @purchaseOrder.observe
    stateOrderDetail = StatePerOrderPurchase.new
    stateOrderDetail.state = @purchaseOrder.human_state_name
    stateOrderDetail.purchase_order_id = params[:id]
    stateOrderDetail.user_id = current_user.id
    stateOrderDetail.save
    redirect_to :action => :index, company_id: params[:company_id]
  end

  def purchase_order_pdf
    @company = Company.find(params[:company_id])
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
    @igv_neto = 0

    @purchaseOrderDetails.each do |pod|
      @total += pod.amount*pod.unit_price
    end

    FinancialVariable.where("name LIKE '%IGV%'").each do |val|
      if val != nil
        @igv= val.value.to_f
      else
        @igv = 0.18
      end
    end

    @igv_neto = @total*@igv
    @total_neto = @total + @igv_neto

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

  def get_exchange_rate_per_date
    render :json => exchange_rate_per_date(params[:date], params[:money_id]).first()
  end

  private
  def purchase_order_parameters
    params.require(:purchase_order).permit(:exchange_of_rate, :date_of_issue, :expiration_date, :delivery_date, :retention, :money_id, :method_of_payment_id, :entity_id, :cost_center_id, :state, :description, purchase_order_details_attributes: [:id, :puchase_order_id, :delivery_order_detail_id, :unit_price, :igv, :amount, :unit_price_igv, :description, :_destroy])
  end
end
