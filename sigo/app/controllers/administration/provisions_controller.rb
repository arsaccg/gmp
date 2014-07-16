class Administration::ProvisionsController < ApplicationController
  def index
    @provision = Provision.all
    render layout: false
  end

  def new
    @provision = Provision.new
    @suppliers = TypeEntity.find_by_preffix("P").entities
    @documentProvisions = DocumentProvision.all
    @cost_center = get_company_cost_center("cost_center")
    render layout: false
  end

  def create
    redirect_to :action => :index
  end

  def edit
    render layout: false
  end

  def update
    redirect_to :action => :index
  end

  def destroy
    render :json => category
  end

  #CUSTOM METHODS
  def display_orders
    @type_order = params[:type_of_order_consult]
    supplier = params[:supplier]
    @supplier_obj = Entity.find(supplier)
    if @type_order == 'purchase_order' 
      @orders = PurchaseOrder.where('entity_id = ?', supplier)
      puts @order.inspect
    elsif @type_order == 'service_order' 
      @orders = OrderOfService.where('entity_id = ?', supplier)
    end
    render(:partial => 'table_list_orders', :layout => false)
  end

  def display_details_orders
    orders = params[:ids_orders]
    @data_orders = Array.new
    if @type_order == 'purchase_order' 
      orders.each do |order|
        if PurchaseOrder.find(order_id).approved?
          PurchaseOrder.find(order_id).purchase_order_details.each do |purchase_detail|
            detail_order = purchase_detail.delivery_order_detail
            @data_orders << [ detail_order.article.code, detail_order.article.name, purchase_detail.amount, purchase_detail.unit_price_igv, purchase_detail.unit_price, purchase_detail.description ]
          end
        end
      end
    elsif @type_order == 'service_order'
      orders.each do |order_id|
        if OrderOfService.find(order_id).approved?
          OrderOfService.find(order_id).order_of_service_details.each do |service_detail|
            order_detail_obtain = service_detail
            @data_orders << [ order_detail_obtain.article.code, order_detail_obtain.article.name, order_detail_obtain.amount, order_detail_obtain.unit_price_igv, order_detail_obtain.unit_price ,order_detail_obtain.description ]
          end
        end
      end
    end
    render(:partial => 'table_list_details_orders', :layout => false)
  end

  private
  def provisions_parameters
    params.require(:provision).permit(:cost_center_id, :entity_id, :document_provision_id, :number_document_provision, :accounting_date, :series, :description)
  end
end
