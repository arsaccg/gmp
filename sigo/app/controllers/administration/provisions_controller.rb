class Administration::ProvisionsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    @provision = Provision.where('order_id IS NOT NULL')
    render layout: false
  end

  def show
    @provision = Provision.find(params[:id])
    @total_without_igv = 0
    @igv = 0
    @total_with_igv = 0

    @provision.provision_direct_purchase_details.each do |provision_detail|
      @total_without_igv += provision_detail.unit_price_before_igv.to_f
      @igv += provision_detail.quantity_igv.to_f
      @total_with_igv += (provision_detail.unit_price_before_igv.to_f+provision_detail.quantity_igv.to_f-provision_detail.discount_after.to_f).to_f
    end
    
    render layout: false  
  end

  def new
    @provision = Provision.new
    @documentProvisions = DocumentProvision.all
    @cost_center = get_company_cost_center("cost_center")
    render layout: false
  end

  def create
    # Si es una provision de Compra Directa
    provision = Provision.new(provision_direct_purchase_parameters)
    flag = Provision.where("entity_id = ? AND series = ? AND number_document_provision = ? AND document_provision_id = 1", provision.entity_id, provision.series,provision.number_document_provision)
    if flag.count == 0
      if provision.save
        provision.provision_direct_purchase_details.each do |pdpd|
          if pdpd.type_order == "purchase_order"
            pod = PurchaseOrderDetail.find(pdpd.order_detail_id)
            if pdpd.amount.to_f == pod.amount.to_f
              pod.update_attributes(:received_provision => 1)
            else
              pod.update_attributes(:received_provision => nil)
            end
          elsif pdpd.type_order == "service_order"
            ood = OrderOfServiceDetail.find(pdpd.order_detail_id)
            if pdpd.amount.to_f == ood.amount.to_f
              ood.update_attributes(:received => 1)
            else
              ood.update_attributes(:received => nil)
            end
          end
        end
        flash[:notice] = "Se ha creado correctamente la nueva provision."
        redirect_to :controller => :provision_articles, :action => :index
      else
        provision.errors.messages.each do |attribute, error|
          flash[:error] = flash[:error].to_s + error.to_s + "  "
        end
        # Load new()
        @provision = provision
        redirect_to :controller => :provision_articles, :action => :new
      end
    else
      flash[:error] = "Ya existe esa factura registrada"
      # Load new()
      @provision = Provision.new(provision_direct_purchase_parameters)
      redirect_to :controller => :provision_articles, :action => :new
    end
  end

  def edit
    @provision = Provision.find(params[:id])
    @documentProvisions = DocumentProvision.all
    @account_accountants = AccountAccountant.where("code LIKE  '_______'")
    @reg_n = ((Time.now.to_f)*100).to_i
    @action = 'edit'
    render layout: false
  end

  def update
    provision = Provision.find(params[:id])
    ver_ids = Array.new
    ver_type = Array.new
    provision.provision_direct_purchase_details.each do |det|
      ver_ids << det.order_detail_id
      ver_type << det.type_order
    end
    provision.update_attributes(provision_direct_purchase_parameters)
    if !ver_ids.include?(nil)
      ver_ids.each do |vid|
        if provision.provision_direct_purchase_details.where("order_detail_id = " + vid.to_s).empty?
          if ver_type[ver_ids.index(vid)] == "purchase_order"
            PurchaseOrderDetail.find(vid).update_attributes(:received_provision => nil)
          elsif ver_type[ver_ids.index(vid)] == "service_order"
            OrderOfServiceDetail.find(vid).update_attributes(:received => nil)
          end
        end
      end
      provision.provision_direct_purchase_details.each do |det|
        if det.type_order == "purchase_order"
          order = PurchaseOrderDetail.find(det.order_detail_id)
          if order.amount == det.amount
            order.update_attributes(:received_provision => 1)
          else
            order.update_attributes(:received_provision => nil)
          end
        elsif det.type_order == "service_order"
          order = OrderOfServiceDetail.find(det.order_detail_id)
          if order.amount == det.amount
            order.update_attributes(:received => 1)
          else
            order.update_attributes(:received => nil)
          end          
        end
      end
    end
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :controller => :provision_articles, :action => :index
  rescue ActiveRecord::StaleObjectError
    provision.reload
    flash[:error] = "Alguien más ha modificado los datos en este instante. Intente Nuevamente."
    redirect_to :action => :index, company_id: params[:company_id]
  end

  def destroy
    provision = Provision.find(params[:id])
    # BEGIN Return all Orders to Received Null
    order_ids = provision.provision_details.select(:order_detail_id).map(&:order_detail_id)
    if provision.provision_details.first.type_of_order == 'purchase_order'
      PurchaseOrderDetail.where(:id => order_ids).each do |purchase_order_detail|
        purchase_order_detail.update_attributes(:received_provision => nil)
      end
    elsif provision.provision_details.first.type_of_order == 'service_order'
      OrderOfService.where(:id => order_ids).each do |order_service|
        order_service.update_attributes(:received => nil)
      end
    end
    # END Return all Orders to Received Null
    provision.provision_details.destroy_all
    provision_destroyed = Provision.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => provision
  end

  #CUSTOM METHODS
  def display_orders
    supplier = params[:supplier]
    @supplier_obj = Entity.find(supplier)
    @orders_po = ActiveRecord::Base.connection.execute("SELECT DISTINCT po.id, po.date_of_issue, po.code, po.description FROM purchase_orders po, purchase_order_details pod, delivery_order_details dod WHERE po.state = 'approved' AND po.id = pod.purchase_order_id AND pod.delivery_order_detail_id = dod.id AND pod.received_provision IS NULL AND po.cost_center_id = " + get_company_cost_center('cost_center').to_s + " AND po.entity_id = " + supplier.to_s)
    @orders_oos = ActiveRecord::Base.connection.execute("SELECT DISTINCT po.id, po.date_of_issue, po.code, po.description FROM order_of_services po, order_of_service_details pod WHERE po.state = 'approved' AND po.id = pod.order_of_service_id AND pod.received IS NULL AND po.cost_center_id = " + get_company_cost_center('cost_center').to_s + " AND po.entity_id = " + supplier.to_s)    

    render(:partial => 'table_list_orders', :layout => false)
  end

  def display_details_orders
    orders = params[:data_orders]
    @data_orders = Array.new

    @igv = FinancialVariable.where("name LIKE '%IGV%'").first.value # IGV in Percent
    if !orders.nil?
      orders.each do |ord|
        type = ord.split("-")

        if type[0]=="OC"
          if PurchaseOrder.find(type[1]).approved?
            PurchaseOrder.find(type[1]).purchase_order_details.each do |purchase_detail|
              if !purchase_detail.received_provision
                detail_order = purchase_detail.delivery_order_detail
                # Lo que falta Atender
                pending = 0
                current_amount = 0
                currency = ''
                provision = ProvisionDirectPurchaseDetail.where(order_detail_id: purchase_detail.id)
                if provision.count > 0
                  provision.each do |prov|
                    current_amount += prov.amount
                  end
                  pending = purchase_detail.amount.to_f - current_amount.to_f
                else
                  pending = purchase_detail.amount.to_f
                end
                currency = purchase_detail.purchase_order.money.symbol
                data_pod = PurchaseOrderDetail.calculate_amounts(purchase_detail.id, pending, purchase_detail.unit_price, @igv)
                order_code = "OC - " + purchase_detail.purchase_order.code
                if pending.to_f > 0.0
                  @data_orders << [ 
                    detail_order.article.code, 
                    detail_order.article.name, 
                    purchase_detail.amount, 
                    data_pod[5].round(2), 
                    purchase_detail.unit_price, 
                    purchase_detail.description, 
                    purchase_detail.id, 
                    pending, 
                    currency, 
                    'purchase',
                    (purchase_detail.quantity_igv.to_f).round(2), 
                    data_pod[3].round(2),
                    order_code
                  ]
                end
              end
            end
          end
          
        elsif type[0]=="OS"
          if OrderOfService.find(type[1]).approved?
            OrderOfService.find(type[1]).order_of_service_details.each do |service_detail|
              if !service_detail.received
                # Lo que falta Atender
                pending = 0
                current_amount = 0
                currency = ''
                provision = ProvisionDetail.where(order_detail_id: service_detail.id)
                if provision.count > 0
                  provision.each do |prov|
                    current_amount += prov.amount
                  end
                  pending = service_detail.amount - current_amount
                else
                  pending = service_detail.amount
                end
                currency = service_detail.order_of_service.money.symbol rescue 'S/.'
                order_code = "OS - " + service_detail.order_of_service.code
                @data_orders << [ 
                  service_detail.article.code, 
                  service_detail.article.name, 
                  service_detail.amount, 
                  (service_detail.unit_price_igv.to_f + service_detail.discount_after.to_f), 
                  service_detail.unit_price_before_igv.to_f, 
                  service_detail.description, 
                  service_detail.id, 
                  pending, 
                  currency, 
                  'service',
                  (service_detail.quantity_igv.to_f*-1).round(2),
                  service_detail.unit_price_before_igv.to_f.round(2),
                  order_code
                ]
              end
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
    # @type_of_order_name = params[:type_of_order]
    # = hidden_field_tag 'provision[provision_details_attributes][' + @reg_n.to_s + '][type_of_order]', @type_of_order_name
    @reg_n = ((Time.now.to_f)*100).to_i
    @account_accountants = AccountAccountant.where("code LIKE  '_______'")
    @sectors = Sector.where("code LIKE '__' AND cost_center_id = " + get_company_cost_center('cost_center').to_s)
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center')).sort

    order_detail_ids.each do |order_detail_id|
      data = order_detail_id.split('-')
      if data[1]!=""
        if data[1]== 'purchase'
          @order = PurchaseOrderDetail.find(data[0])
          @order_ec = @order.purchase_order_extra_calculations.where("apply LIKE 'before' AND extra_calculation_id = 1")
          @type_order = "purchase_order"
          @article_id = @order.delivery_order_detail.article.id
          @article_code = @order.delivery_order_detail.article.code
          @article_name = @order.delivery_order_detail.article.name
          @article_unit = @order.delivery_order_detail.article.unit_of_measurement.symbol
          @money = @order.purchase_order.money.symbol
          @sector = @order.delivery_order_detail.sector_id
          @phase = @order.delivery_order_detail.phase_id
          @code = @order.purchase_order.code.to_s.rjust(5, '0')
          @money_id = @order.purchase_order.money_id
          @exchange_rate = @order.purchase_order.exchange_of_rate
        elsif data[1]== 'service'
          @order = OrderOfServiceDetail.find(data[0])
          @order_ec = @order.order_service_extra_calculations.where("apply LIKE 'before' AND extra_calculation_id = 1")
          @type_order = "service_order"
          @article_id = @order.article.id
          @article_code = @order.article.code
          @article_name = @order.article.name
          @article_unit = @order.article.unit_of_measurement.symbol
          @money  = @order.order_of_service.money.symbol
          @sector = @order.sector_id
          @phase = @order.phase_id
          @code = @order.order_of_service.code.to_s.rjust(5, '0') 
          @money_id = @order.order_of_service.money_id
          @exchange_rate = @order.order_of_service.exchange_of_rate
        end
      end

      if @order.igv
        @igv = 0.18
      else
        @igv = 0
      end

      # Lo que falta Atender
      pending = 0
      total = 0
      provision = ProvisionDirectPurchaseDetail.where("order_detail_id  = "+ @order.id.to_s)
      if provision.count > 0
        amount = 0
        provision.each do |pd|
          amount += pd.amount.to_f
        end
        pending = @order.amount.to_f - amount.to_f
      else
        pending = @order.amount
      end
      con_igv = pending.to_f*@order.unit_price.to_f
      discounts_before = 0
      @order_ec.each do |extra_calculation|
        if extra_calculation.type == 'percent'
          value = extra_calculation.value.to_f/100
          if extra_calculation.operation == "sum"
            discounts_before += (con_igv*value)*-1
          else
            discounts_before += con_igv*value
          end
        elsif extra_calculation.type == 'soles'
          value = extra_calculation.value.to_f
          if extra_calculation.operation == "sum"
            discounts_before += (value*-1)
          else
            discounts_before += value
          end
        end
      end
      if @igv > 0.00
        quantity_igv = (con_igv.to_f-discounts_before.to_f)*@igv.to_f
      else
        quantity_igv = 0
      end
      @data_orders << [ 
        @order.id, 
        @article_code, 
        @article_name, 
        @article_unit, 
        pending, 
        @order.unit_price,
        discounts_before,
        (con_igv.to_f-discounts_before.to_f).round(4).round(2),
        @igv,
        quantity_igv.round(4).round(2),
        ((con_igv.to_f-discounts_before.to_f)*(1+@igv.to_f)).round(4).round(2),
        @money,
        @article_id,
        @code,
        @sector,
        @phase,
        @type_order,
        @money_id,
        @exchange_rate
      ]
    end

    render(:partial => 'row_detail_provision', :layout => false)
  end

  def get_tc_with_date
    tc = ExchangeOfRate.where("day = ?",params[:date])
    @tc = Array.new
    tc.each do |tc|
      @tc << {'value'=>tc.value, 'flag'=>true}
    end
    render json: {:tc => @tc}      
  end  

  def get_suppliers_by_type_order
    str_options = ''
    aux = Array.new
    if params[:type] == 'purchase_order'
      PurchaseOrder.all.each do |purchase|
        if !aux.include? purchase.entity.id
          aux << purchase.entity.id
          str_options += ('<option value=' + purchase.entity.id.to_s + '>' + purchase.entity.ruc.to_s + ' - ' + purchase.entity.name.to_s + ' ' + purchase.entity.paternal_surname.to_s + ' ' + purchase.entity.maternal_surname.to_s + '</option>')
        end
      end
    elsif params[:type] == 'service_order'
      OrderOfService.all.each do |service|
        if !aux.include? service.entity.id
          aux << service.entity.id
          str_options += ('<option value=' + service.entity.id.to_s + '>' + service.entity.ruc.to_s + ' - ' + service.entity.name.to_s + ' ' + service.entity.paternal_surname.to_s + ' ' + service.entity.maternal_surname.to_s + '</option>')
        end
      end
    end
        
    render json: {:suppliers => str_options}
  end

  private
  def provision_direct_purchase_parameters
    params.require(:provision).permit(
      :cost_center_id, 
      :entity_id, 
      :document_provision_id, 
      :lock_version, 
      :number_document_provision, 
      :accounting_date, 
      :series, 
      :rendicion,
      :description,
      :number_of_guide,
      :money_id,
      :exchange_of_rate,
      provision_direct_purchase_details_attributes: [
        :id,
        :provision_id,
        :article_id,
        :sector_id,
        :phase_id,
        :account_accountant_id,
        :amount,
        :price, 
        :lock_version,
        :unit_price_before_igv,
        :igv,
        :quantity_igv,
        :flag,
        :type_order,
        :order_detail_id,
        :discount_before,
        :unit_price_igv,
        :description,
        :_destroy,
        provision_direct_extra_calculations_attributes: [
          :id,
          :provision_direct_purchase_detail_id,
          :extra_calculation_id,
          :value,
          :apply,
          :operation,
          :type,
          :_destroy
        ]
      ]
    )
  end
end
