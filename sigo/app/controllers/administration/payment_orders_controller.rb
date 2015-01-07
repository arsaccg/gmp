class Administration::PaymentOrdersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    @paymentOrders = PaymentOrder.where("cost_center_id ="+get_company_cost_center('cost_center').to_s)
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
        @total_quantity += provision_detail.unit_price_before_igv.to_f # Precio antes de IGV
        @total_quantity_with_igv += provision_detail.unit_price_igv.to_f # Precio despues de IGV
      end
    end

    render layout: false    
  end

  def new
    @paymentOrder = PaymentOrder.new
    @provisions = Provision..where("cost_center_id ="+get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def create
    paymentOrder = PaymentOrder.new(payment_order_parameters)
    codes = Array.new
    Provision.find(paymentOrder.provision_id).provision_direct_purchase_details.each do |p|
      codes << p.article.code
    end
    codes = codes.join('-')
    paymentOrder.cost_center_id = get_company_cost_center('cost_center')
    paymentOrder.article_code = codes
    if paymentOrder.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      paymentOrder.errors.messages.each do |attribute, error|
      end
      @paymentOrder = paymentOrder
      render :new, layout: false 
    end
  end

  def edit
    @paymentOrder = PaymentOrder.find(params[:id])
    @provisions = Provision.where("cost_center_id ="+get_company_cost_center('cost_center').to_s)
    @action = 'edit'
    render layout: false
  end

  def update
    paymentOrder = PaymentOrder.find(params[:id])
    codes = Array.new
    Provision.find(paymentOrder.provision_id).provision_direct_purchase_details.each do |p|
      codes << p.article.code
    end
    codes = codes.join('-')
    paymentOrder.article_code = codes    
    paymentOrder.cost_center_id = get_company_cost_center('cost_center')
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
        @budget = CostCenter.find(get_company_cost_center('cost_center')).budgets.where("type_of_budget = 0").first.id
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
        @consumido = 0

        @payment_order.provision.provision_direct_purchase_details.each do |payment_detail|
          obj = nil
          @articles_ids = Array.new
          
          if !payment_detail.order_detail_id.nil?
            if payment_detail.type_order == 'purchase_order'
              obj = PurchaseOrderDetail.find(payment_detail.order_detail_id).purchase_order
              
              obj.purchase_order_details.each do |pod|
                a = Article.find_specific_in_article( pod.delivery_order_detail.article_id, get_company_cost_center('cost_center')).first
                @articles_ids << a[0]
                @articles_code = a[3]
              end

            else
              obj = OrderOfServiceDetail.find(payment_detail.order_detail_id).order_of_service
              obj.order_of_service_details.each do |pod|
                a = Article.find_specific_in_article(pod.article_id, get_company_cost_center('cost_center')).first
                @articles_ids << a[0]
                @articles_code = a[3]
              end              
            end

            if (!obj.nil?) && (@articles_ids.count != 0)

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
              @consumido= ActiveRecord::Base.connection.execute("
                SELECT (SUM(total)-(SUM(detraction)+SUM(guarantee_fund_n1)+SUM(other_discounts)))
                FROM payment_orders
                WHERE article_code LIKE  '%"+@articles_code.to_s+"%'
                AND id NOT IN ("+@payment_order.id.to_s+")
                AND id < "+@payment_order.id.to_s+"
                ").first[0].to_f
              # Código Tobi
              @consumido += @payment_order.total.to_f - (@payment_order.detraction.to_f + @payment_order.guarantee_fund_n1.to_f + @payment_order.other_discounts.to_f)
              @codes_tobi << [PaymentOrder.get_tobi_codes(@articles_ids, @cost_center.id),PaymentOrder.get_amount_feo_by_code_phase(@articles_code.to_s[0..5],@budget),@consumido]
              @consumido = 0
            end
          else
            a = Article.find_specific_in_article(payment_detail.article_id, get_company_cost_center('cost_center')).first
            @articles_ids << a[0]
            @articles_code = a[3]
            @consumido= ActiveRecord::Base.connection.execute("
                SELECT (SUM(total)-(SUM(detraction)+SUM(guarantee_fund_n1)+SUM(other_discounts)))
                FROM payment_orders
                WHERE article_code LIKE  '%"+@articles_code.to_s+"%'
                AND id NOT IN ("+@payment_order.id.to_s+")
                AND id < "+@payment_order.id.to_s+"
                ").first[0].to_f
            @consumido += @payment_order.total.to_f - (@payment_order.detraction.to_f + @payment_order.guarantee_fund_n1.to_f + @payment_order.other_discounts.to_f)
            @codes_tobi << [PaymentOrder.get_tobi_codes(@articles_ids, @cost_center.id), PaymentOrder.get_amount_feo_by_code_phase(@articles_code.to_s[0..5],@budget),@consumido]
              @consumido = 0
          end

        end
        @subject = @payment_order.provision.description
        @codes_tobi= @codes_tobi.uniq

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
      :sub_total,
      :type_payment
    )
  end
end
