class Administration::ProvisionArticlesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @provision = Provision.all
    render layout: false
  end

  def new
    @provision = Provision.new
    @documentProvisions = DocumentProvision.all
    @cost_center = get_company_cost_center("cost_center")
    render layout: false
  end

  def create
    provision = Provision.new(provisions_parameters)
    if provision.save
      provision_checked = Array.new
      total_amount = 0
      provision.provision_details.each do |detail|
        if !provision_checked.include? detail
          provision_checked << detail.order_detail_id
          ProvisionDetail.where('order_detail_id = ?', detail.order_detail_id).each do |details|
            total_amount += details.amount
          end
          Provision.update_received_order(total_amount, detail.order_detail_id, detail.type_of_order)
        end
      end
      flash[:notice] = "Se ha creado correctamente la nueva provision."
      redirect_to :action => :index
    else
      provision.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @provision = provision
      render :new, layout: false
    end
  end

  def edit
    @provision = Provision.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    provision = Provision.find(params[:id])
    if provision.update_attributes(provisions_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      provision.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @provision = provision
      render :edit, layout: false
    end
  end

  def destroy
    provision = Provision.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => provision
  end

  #CUSTOM METHODS
  def display_orders
    @type_order = params[:type_of_order_consult]
    supplier = params[:supplier]
    @supplier_obj = Entity.find(supplier)
    if @type_order == 'purchase_order' 
      @orders = PurchaseOrder.where('entity_id = ? AND state = ?', supplier, 'approved')
    elsif @type_order == 'service_order' 
      @orders = OrderOfService.where('entity_id = ? AND state = ?', supplier, 'approved')
    end
    render(:partial => 'table_list_orders', :layout => false)
  end

  def display_details_orders
    orders = params[:ids_orders]
    @type_order = params[:type_of_order_selected]
    @data_orders = Array.new
    if @type_order == 'purchase_order' 
      orders.each do |order_id|
        if PurchaseOrder.find(order_id).approved?
          PurchaseOrder.find(order_id).purchase_order_details.each do |purchase_detail|
            if !purchase_detail.received_provision
              detail_order = purchase_detail.delivery_order_detail
              # Lo que falta Atender
              pending = 0
              current_amount = 0
              provision = ProvisionDetail.where(order_detail_id: purchase_detail.id)
              if provision.count > 0
                provision.each do |prov|
                  current_amount += prov.amount
                end
                pending = purchase_detail.amount - current_amount
              else
                pending = purchase_detail.amount
              end
              @data_orders << [ detail_order.article.code, detail_order.article.name, purchase_detail.amount, purchase_detail.unit_price_igv, purchase_detail.unit_price, purchase_detail.description, purchase_detail.id, pending ]
            end
          end
        end
      end
    elsif @type_order == 'service_order'
      orders.each do |order_id|
        if OrderOfService.find(order_id).approved?
          OrderOfService.find(order_id).order_of_service_details.each do |service_detail|
            if !service_detail.received
              # Lo que falta Atender
              pending = 0
              current_amount = 0
              provision = ProvisionDetail.where(order_detail_id: service_detail.id)
              if provision.count > 0
                provision.each do |prov|
                  current_amount += prov.amount
                end
                pending = service_detail.amount - current_amount
              else
                pending = service_detail.amount
              end
              @data_orders << [ service_detail.article.code, service_detail.article.name, service_detail.amount, (service_detail.unit_price_igv.to_f + service_detail.discount_after.to_f), service_detail.unit_price_before_igv.to_f, service_detail.description, service_detail.id, pending ]
            end
          end
        end
      end
    end
    render(:partial => 'table_list_details_orders', :layout => false)
  end

  def puts_details_in_provision
    @data_orders = Array.new
    order_detail_ids = params[:ids_orders_details]
    @type_of_order_name = params[:type_of_order]
    @reg_n = ((Time.now.to_f)*100).to_i
    @account_accountants = AccountAccountant.all

    if @type_of_order_name == 'purchase_order' 
      order_detail_ids.each do |order_detail_id|
        purchase_order_detail = PurchaseOrderDetail.find(order_detail_id)
        igv = 0
        if purchase_order_detail.igv != nil
          igv = (purchase_order_detail.unit_price_igv/(purchase_order_detail.amount*purchase_order_detail.unit_price))-1
        end
        # Lo que falta Atender
        pending = 0
        total = 0
        provision = ProvisionDetail.find_by_order_detail_id(purchase_order_detail.id)
        if !provision.nil?
          pending = purchase_order_detail.amount - provision.amount
          total = pending*purchase_detail.unit_price*(1+igv)
        else
          pending = purchase_order_detail.amount
          total = purchase_order_detail.unit_price_igv
        end
        @data_orders << [ purchase_order_detail.id, purchase_order_detail.delivery_order_detail.article.code, purchase_order_detail.delivery_order_detail.article.name, purchase_order_detail.delivery_order_detail.article.unit_of_measurement.symbol, purchase_order_detail.amount, purchase_order_detail.unit_price, total, igv, pending ]
      end
    elsif @type_of_order_name == 'service_order'
      order_detail_ids.each do |order_detail_id|
        service_order_detail = OrderOfServiceDetail.find(order_detail_id)
        igv = 0
        if service_order_detail.igv != nil
          igv = (-1*service_order_detail.quantity_igv/(service_order_detail.unit_price_before_igv))
        end
        # Lo que falta Atender
        pending = 0
        total = 0 
        total_neto = 0 
        provision = ProvisionDetail.find_by_order_detail_id(service_order_detail.id)
        if !provision.nil?
          pending = service_order_detail.amount - provision.amount
          total = (((pending * service_order_detail.unit_price) + service_order_detail.discount_before.to_i) * (1 + igv))
          total_neto = total + service_order_detail.discount_after.to_i
        else
          pending = service_order_detail.amount
          total = service_order_detail.unit_price_igv
          total_neto = total + service_order_detail.discount_after.to_i
        end
        @data_orders << [ 
          service_order_detail.id, 
          service_order_detail.article.code, 
          service_order_detail.article.name, 
          service_order_detail.article.unit_of_measurement.symbol, 
          service_order_detail.amount, 
          service_order_detail.unit_price,
          total, 
          igv, 
          pending,
          service_order_detail.discount_before.to_i*-1,
          service_order_detail.discount_after.to_i,
          total_neto
        ]
      end
    end

    render(:partial => 'row_detail_provision', :layout => false)
  end

  def get_suppliers_by_type_order
    str_options = ''
    aux = Array.new
    if params[:type] == 'purchase_order'
      PurchaseOrder.all.each do |purchase|
        if !aux.include? purchase.entity.id
          aux << purchase.entity.id
          str_options += ('<option value=' + purchase.entity.id.to_s + '>' + purchase.entity.name.to_s + ' ' + purchase.entity.paternal_surname.to_s + ' ' + purchase.entity.maternal_surname.to_s + '</option>')
        end
      end
    elsif params[:type] == 'service_order'
      OrderOfService.all.each do |service|
        if !aux.include? service.entity.id
          aux << service.entity.id
          str_options += ('<option value=' + service.entity.id.to_s + '>' + service.entity.name.to_s + ' ' + service.entity.paternal_surname.to_s + ' ' + service.entity.maternal_surname.to_s + '</option>')
        end
      end
    end
        
    render json: {:suppliers => str_options}
  end

  private
  def provisions_parameters
    params.require(:provision).permit(
      :cost_center_id, 
      :entity_id, 
      :document_provision_id, 
      :number_document_provision, 
      :accounting_date, 
      :series, 
      :description,
      provision_details_attributes: [
        :id,
        :provision_id,
        :current_unit_price,
        :current_igv,
        :order_detail_id,
        :type_of_order,
        :account_accountant_id,
        :amount,
        :unit_price_igv,
        :_destroy
      ]
    )
  end
end
