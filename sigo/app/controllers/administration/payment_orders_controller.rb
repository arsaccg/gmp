class Administration::PaymentOrdersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    @paymentOrders = PaymentOrder.all
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
    provision = Provision.find(params[:provision_id])
    igv = 0
    total_quantity = 0
    total_quantity_without_igv = 0 # Valor que contiene solo CantdxPrecio.
    total_quantity_with_igv = 0 # Valor que contiene el IGV sumado a la anterior variable.

    if provision.order_id != nil
      provision.provision_details.each do |provision_detail|
        total_quantity += provision_detail.unit_price_igv.to_f # Precio antes de IGV
        #total_quantity_with_igv += provision_detail.net_price_after_igv.to_f # Precio despues de IGV

        total_quantity_without_igv += (provision_detail.current_unit_price*provision_detail.amount)
        total_quantity_with_igv += (provision_detail.current_unit_price*provision_detail.amount) + (provision_detail.current_igv*(provision_detail.current_unit_price*provision_detail.amount))
      end
    else
      provision.provision_direct_purchase_details.each do |provision_detail|
        total_quantity += provision_detail.unit_price_before_igv # Precio antes de IGV
        total_quantity_with_igv += provision_detail.unit_price_igv # Precio despues de IGV
      end
    end

    igv = (((total_quantity_with_igv.to_f - total_quantity_without_igv.to_f) / total_quantity_without_igv.to_f).round(2))*total_quantity_without_igv

    data_provision = [
      :type_document_provision => provision.document_provision.name, 
      :number_document_provision => provision.number_document_provision, 
      :date_doc_provision => provision.accounting_date, 
      :supplier_provision => provision.entity.name.to_s + ' ' + provision.entity.paternal_surname.to_s + ' ' + provision.entity.maternal_surname.to_s, 
      :total_quantity_provision => total_quantity_without_igv.round(2),
      :total_quantity_provision_with_igv => total_quantity_with_igv.round(2),
      :igv => igv.round(0)
    ]

    render json: { :provision => data_provision }
  end

  private
  def payment_order_parameters
    params.require(:payment_order).permit(:provision_id, :net_pay, :igv, :percent_detraction, :detraction, :cost_center_id)
  end
end
