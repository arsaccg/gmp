class Administration::PaymentOrdersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    @paymentOrders = PaymentOrder.all
    @workers = ""
    TypeEntity.find_by_preffix('T').entities.each do |entity|
      @workers += '[' + entity.name.to_s + ' ' + entity.second_name.to_s + ' ' + entity.paternal_surname.to_s + ' ' + entity.maternal_surname.to_s + ']'
    end
    render layout: false
  end

  def show
    @paymentOrder = PaymentOrder.find(params[:id])
    provision = @paymentOrder.provision
    @total_quantity = 0
    @total_quantity_with_igv = 0

    if provision.order_id != nil
      provision.provision_details.each do |provision_detail|
        @total_quantity += provision_detail.unit_price_igv.to_f # Precio antes de IGV
        @total_quantity_with_igv += provision_detail.net_price_after_igv.to_f # Precio despues de IGV
      end
    else
      provision.provision_direct_purchase_details.each do |provision_detail|
        @total_quantity += provision_detail.unit_price_before_igv # Precio antes de IGV
        @total_quantity_with_igv += provision_detail.unit_price_igv # Precio despues de IGV
      end
    end

    render layout: false    
  end

  def new
    @paymentOrder = PaymentOrder.new
    @provisions = Provision.all
    render layout: false
  end

  def create
    paymentOrder = PaymentOrder.new(payment_order_parameters)
    codes = Array.new
    Provision.find(paymentOrder.provision_id).provision_details.each do |p|
      if p.type_of_order=="purchase_order"
        codes << PurchaseOrderDetail.find(p.order_detail_id).delivery_order_detail.article.code
      elsif p.type_of_order=="order_service"
        codes << OrderoOServiceDetail.find(p.order_detail_id).delivery_order_detail.article.code
      end
    end
    codes = codes.join('-')
    paymentOrder.article_code = codes
    if paymentOrder.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      paymentOrder.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @paymentOrder = paymentOrder
      render :new, layout: false 
    end
  end

  def edit
    @paymentOrder = PaymentOrder.find(params[:id])
    @provisions = Provision.all
    @action = 'edit'
    render layout: false
  end

  def update
    paymentOrder = PaymentOrder.find(params[:id])
    codes = Array.new
    Provision.find(paymentOrder.provision_id).provision_details.each do |p|
      if p.type_of_order=="purchase_order"
        codes << PurchaseOrderDetail.find(p.order_detail_id)..article.code
      elsif p.type_of_order=="order_service"
        codes << OrderoOServiceDetail.find(p.order_detail_id).delivery_order_detail.article.code
      end
    end
    codes = codes.join('-')
    paymentOrder.article_code = codes    
    if paymentOrder.update_attributes(payment_order_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      paymentOrder.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @paymentOrder = paymentOrder
      render :edit, layout: false
    end
  end

  def destroy
    paymentOrder = PaymentOrder.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente la orden de pago."
    render :json => paymentOrder
  end

  # CUSTOM METHODS
  def get_info_from_provision
    data_provision = Array.new
    if params[:provision_id] != "Seleccionar alguna de las Provisiones"
      provision = Provision.find(params[:provision_id])
      igv = 0
      perception = 0
      total_quantity = 0
      total_quantity_without_igv = 0 # Valor que contiene solo CantdxPrecio.
      total_quantity_with_igv = 0 # Valor que contiene el IGV sumado a la anterior variable.

      provision.provision_direct_purchase_details.each do |provision_detail|
        total_quantity_without_igv += provision_detail.unit_price_before_igv.to_f
        total_quantity_with_igv += provision_detail.unit_price_before_igv.to_f + provision_detail.quantity_igv.to_f + provision_detail.discount_after.to_f
        igv =  provision_detail.quantity_igv.to_f
        # perception += provision_detail.amount_perception.to_f
      end

      data_provision = [
        :type_document_provision => provision.document_provision.name, 
        :number_document_provision => provision.number_document_provision, 
        :date_doc_provision => provision.accounting_date, 
        :supplier_provision => provision.entity.name.to_s + ' ' + provision.entity.paternal_surname.to_s + ' ' + provision.entity.maternal_surname.to_s, 
        :perception => perception,
        :total_quantity_provision => total_quantity_without_igv.round(2),
        :total_quantity_provision_with_igv => total_quantity_with_igv.round(2),
        :igv => igv.round(2)
      ]
    else
      data_provision = [
        :type_document_provision => "",
        :number_document_provision => "", 
        :date_doc_provision => "", 
        :supplier_provision => "", 
        :perception => 0,
        :total_quantity_provision => 0,
        :total_quantity_provision_with_igv => 0,
        :igv => 0
      ]
    end

    render json: { :provision => data_provision }
  end

  def generate_payslip
    respond_to do |format|
      format.html
      format.pdf do

        @destinatary = params[:destinatary]
        @payment_order = PaymentOrder.find(params[:id])
        @cost_center = CostCenter.find(get_company_cost_center('cost_center'))
        @company = Company.find(get_company_cost_center('company'))
        @current_user = current_user.first_name.to_s + ' ' + current_user.last_name.to_s + ' ' + current_user.surname
        @codes_orders = Array.new
        @suppliers = Array.new
        @ruc = Array.new
        @codes_tobi = Array.new
        @itembybudget_details = Array.new

        @payment_order.provision.provision_details.each do |payment_detail|
          
          obj = nil
          articles_ids = 0

          if payment_detail.type_of_order == 'purchase_order'
            obj = PurchaseOrderDetail.find(payment_detail.order_detail_id).purchase_order
            
            obj.purchase_order_details.each do |pod|
              articles_ids = pod.delivery_order_detail.article_id
            end

          else
            obj = OrderOfServiceDetail.find(payment_detail.order_detail_id).order_service
            articles_ids = obj.order_service_details.select(:article_id).map(&:article_id)
          end

          if (!obj.nil?) && (articles_ids != 0)

            # Código de Ordenes
            @codes_orders << obj.id.to_s.rjust(5,'0')
            # Nombre de Proveedores
            if !@suppliers.include? (obj.entity.name.to_s + ' ' + obj.entity.second_name.to_s + ' ' + obj.entity.paternal_surname.to_s + ' ' + obj.entity.maternal_surname.to_s)
              @suppliers << obj.entity.name.to_s + ' ' + obj.entity.second_name.to_s + ' ' + obj.entity.paternal_surname.to_s + ' ' + obj.entity.maternal_surname.to_s
            end
            # RUC de Proveedores
            if !@ruc.include? obj.entity.ruc.to_s
              @ruc << obj.entity.ruc.to_s
            end

            # Código Tobi
            @codes_tobi << PaymentOrder.get_tobi_codes(articles_ids, @cost_center.id)
          end

        end

        @subject = @payment_order.provision.description

        render :pdf => "Orden_de_pago-#{Time.now.strftime('%d-%m-%Y')}", 
               :template => 'administration/payment_orders/payslip_pdf.pdf.haml',
               :page_size => 'A3',
               :orientation => 'Landscape',
               #:show_as_html => true,
               :dpi => '300'
      end
    end
  end

  private
  def payment_order_parameters
    params.require(:payment_order).permit(
      :provision_id, 
      :net_pay, 
      :igv, 
      :percent_detraction, 
      :detraction, 
      :guarantee_fund_n1, 
      :other_discounts, 
      :cost_center_id,
      :perception,
      :total,
      :sub_total
    )
  end
end
