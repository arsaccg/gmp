class Administration::ProvisionsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    @provision = Provision.where('order_id IS NOT NULL')
    render layout: false
  end

  def show
    @provision = Provision.find(params[:id])
    render layout: false  
  end

  def new
    @provision = Provision.new
    @documentProvisions = DocumentProvision.all
    @cost_center = get_company_cost_center("cost_center")
    render layout: false
  end

  def create
    # Si es una Provision de Compra
    if params[:provision]['order_id'] != nil
      provision = Provision.new(provisions_parameters)
      flag = Provision.where("entity_id = ? AND series = ? AND number_document_provision = ? AND document_provision_id = 1", provision.entity_id, provision.series,provision.number_document_provision)
      if flag.count ==0
        if provision.save
          provision_checked = Array.new
          total_amount = 0
          provision.provision_details.each do |detail|
            if !provision_checked.include? detail.order_detail_id
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
      else
        provision.errors.messages.each do |attribute, error|
          flash[:error] =  "Ya existe esa factura registrada con los mismos datos"
        end
        # Load new()
        @provision = provision
        render :new, layout: false
      end
      
    else
      # Si es una provision de Compra Directa
      provision = Provision.new(provision_direct_purchase_parameters)
      flag = Provision.where("entity_id = ? AND series = ? AND number_document_provision = ? AND document_provision_id = 1", provision.entity_id, provision.series,provision.number_document_provision)
      if flag.count == 0
        if provision.save
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
    if params[:provision]['order_id'] != nil
      provision = Provision.find(params[:id])
      provision.update_attributes(provisions_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      provision = Provision.find(params[:id])
      provision.update_attributes(provision_direct_purchase_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :controller => :provision_articles, :action => :index
    end
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
    @orders_po = PurchaseOrder.select(:id).select(:date_of_issue).select(:code).select(:description).where('entity_id = ? AND state = ?', supplier, 'approved')
    @orders_oos = OrderOfService.where('entity_id = ? AND state = ?', supplier, 'approved')

    render(:partial => 'table_list_orders', :layout => false)
  end

  def display_details_orders
    orders_po = params[:data_orders_po]
    orders_oos = params[:data_orders_oos]
    @type_order = params[:type_of_order_selected]
    @data_orders = Array.new

    @igv = FinancialVariable.where("name LIKE '%IGV%'").first.value # IGV in Percent

    if !orders_po.nil?
      orders_po.each do |order_id|
        if PurchaseOrder.find(order_id).approved?
          PurchaseOrder.find(order_id).purchase_order_details.each do |purchase_detail|
            if !purchase_detail.received_provision
              detail_order = purchase_detail.delivery_order_detail
              # Lo que falta Atender
              pending = 0
              current_amount = 0
              currency = ''
              provision = ProvisionDetail.where(order_detail_id: purchase_detail.id)
              if provision.count > 0
                provision.each do |prov|
                  current_amount += prov.amount
                end
                pending = purchase_detail.amount - current_amount
              else
                pending = purchase_detail.amount
              end
              currency = purchase_detail.purchase_order.money.symbol

              data_pod = PurchaseOrderDetail.calculate_amounts(purchase_detail.id, pending, purchase_detail.unit_price, @igv)
              
              if pending > 0
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
                  (purchase_detail.quantity_igv.to_f*-1).round(2), 
                  data_pod[3].round(2)
                ]
              end
            end
          end
        end
      end
    end

    if !orders_oos.nil?
      orders_oos.each do |order_id|
        if OrderOfService.find(order_id).approved?
          OrderOfService.find(order_id).order_of_service_details.each do |service_detail|
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
                service_detail.unit_price_before_igv.to_f.round(2)
              ]
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
    @sectors = Sector.where("code LIKE '__' ")
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center')).sort

    @igv = FinancialVariable.where("name LIKE '%IGV%'").first.value # IGV in Percent

    order_detail_ids.each do |order_detail_id|
      data = order_detail_id.split('-')
      if data[1] == 'purchase'
        purchase_order_detail = PurchaseOrderDetail.find(data[0])

        # Lo que falta Atender
        pending = 0
        total = 0
        percepcion = purchase_order_detail.purchase_order_extra_calculations.find_by_extra_calculation_id(2)
        provision = ProvisionDetail.where("order_detail_id  = "+ purchase_order_detail.id.to_s)
        if provision.count > 0
          amount = 0
          provision.each do |pd|
            amount += pd.amount
          end
          pending = purchase_order_detail.amount - amount
          some_results = PurchaseOrderDetail.calculate_amounts(data[0], pending, purchase_order_detail.unit_price, @igv)
          #total = (pending*purchase_order_detail.unit_price*(1+igv))
          if !percepcion.nil?
            if percepcion.type=="soles"
              percepcion = (percepcion.value.to_f+some_results[4].round(2))
            else
              percepcion = ((percepcion.value.to_f/100)*some_results[4].round(2))
            end
          else
            percepcion = 0
          end

          @data_orders << [ 
            purchase_order_detail.id, 
            purchase_order_detail.delivery_order_detail.article.code, 
            purchase_order_detail.delivery_order_detail.article.name, 
            purchase_order_detail.delivery_order_detail.article.unit_of_measurement.symbol, 
            purchase_order_detail.amount, 
            purchase_order_detail.unit_price, 
            some_results[3].round(2), 
            @igv, 
            pending, 
            some_results[1], 
            some_results[2],
            some_results[4].round(2),
            percepcion,
            purchase_order_detail.purchase_order.money.symbol,
            purchase_order_detail.delivery_order_detail.article.id,
            purchase_order_detail.purchase_order.code.to_s.rjust(5, '0')
          ]
        else
          pending = purchase_order_detail.amount
          total = (purchase_order_detail.unit_price.to_f * purchase_order_detail.amount.to_f).to_f - purchase_order_detail.discount_before.to_f
          if !percepcion.nil?
            if percepcion.type=="soles"
              percepcion = (percepcion.value.to_f+total)
            else
              percepcion = ((percepcion.value.to_f/100)*total)
            end
          else
            percepcion = 0
          end

          some_results = PurchaseOrderDetail.calculate_amounts(data[0], pending, purchase_order_detail.unit_price, @igv)

          @data_orders << [ 
            purchase_order_detail.id, 
            purchase_order_detail.delivery_order_detail.article.code, 
            purchase_order_detail.delivery_order_detail.article.name, 
            purchase_order_detail.delivery_order_detail.article.unit_of_measurement.symbol, 
            purchase_order_detail.amount, 
            purchase_order_detail.unit_price, 
            some_results[3].round(2), 
            @igv, 
            pending, 
            some_results[1].abs, 
            some_results[2],
            some_results[4].round(2),
            percepcion,
            purchase_order_detail.purchase_order.money.symbol,
            purchase_order_detail.delivery_order_detail.article.id,
            purchase_order_detail.delivery_order_detail.phase_id,
            purchase_order_detail.delivery_order_detail.sector_id,
            purchase_order_detail.purchase_order.code.to_s.rjust(5, '0')
          ]

        end
      elsif data[1] == 'service'
        service_order_detail = OrderOfServiceDetail.find(data[0])
        igv = 0
        if service_order_detail.igv != nil
          igv = (-1*service_order_detail.quantity_igv)/(service_order_detail.unit_price_before_igv)
        end
        # Lo que falta Atender
        pending = 0
        total = 0 
        total_neto = 0 
        percepcion_value = 0
        provision = ProvisionDetail.find_by_order_detail_id(service_order_detail.id)
        percepcion = service_order_detail.order_service_extra_calculations.find_by_extra_calculation_id(2)
        
        if !provision.nil?
          pending = service_order_detail.amount - provision.amount
          total = (((pending * service_order_detail.unit_price) + service_order_detail.discount_before.to_i) * (1 + igv))
          total_neto = total + service_order_detail.discount_after.to_i
        else
          pending = service_order_detail.amount
          total = service_order_detail.unit_price_igv
          total_neto = total + service_order_detail.discount_after.to_i
        end

        if percepcion.nil?
          percepcion="0.00"
          percepcion_value = 0
        else        
          if percepcion.type=="soles"
            percepcion = "S/. "+percepcion.value.to_f.to_s
            percepcion_value = percepcion.value.to_f
          else
            percepcion = percepcion.value.to_f.to_s + "%"
            percepcion_value = total*(percepcion.value.to_f/100)
          end
        end

        @data_orders << [ 
          service_order_detail.id, # [0]
          service_order_detail.article.code, # [1]
          service_order_detail.article.name, # [2]
          service_order_detail.article.unit_of_measurement.symbol, # [3]
          service_order_detail.amount, # [4]
          service_order_detail.unit_price, # [5]
          total, # [6]
          igv, # [7]
          pending, # [8]
          service_order_detail.discount_before.to_i*-1, # [9]
          service_order_detail.discount_after.to_i, # [10]
          (total_neto-percepcion_value), # [11]
          percepcion, # [12]
          service_order_detail.order_of_service.money.symbol, # [13]
          service_order_detail.article.id,
          service_order_detail.phase_id,
          service_order_detail.sector_id,
          service_order_detail.order_of_service.code.to_s.rjust(5, '0')
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
  def provisions_parameters
    params.require(:provision).permit(
      :cost_center_id, 
      :entity_id, 
      :order_id, 
      :lock_version,
      :document_provision_id, 
      :number_document_provision, 
      :accounting_date, 
      :series, 
      :description,
      provision_details_attributes: [
        :id,
        :provision_id,
        :article_code,
        :article_name,
        :amount_perception,
        :discount_before_igv,
        :discount_after_igv,
        :unit_of_measurement,
        :current_unit_price,
        :current_igv, 
        :lock_version,
        :order_detail_id,
        :type_of_order,
        :account_accountant_id,
        :amount,
        :unit_price_igv,
        :net_price_after_igv,
        :_destroy
      ]
    )
  end

  def provision_direct_purchase_parameters
    params.require(:provision).permit(
      :cost_center_id, 
      :entity_id, 
      :document_provision_id, 
      :lock_version, 
      :number_document_provision, 
      :accounting_date, 
      :series, 
      :description,
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
        #:discount_after,
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
