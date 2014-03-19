class Logistics::MethodOfPaymentsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  def index
    flash[:error] = nil
    @methodOfPayments = MethodOfPayment.all
    render layout: false
  end

  def show
    render :json => nil
  end

  def new
    @methodOfPayments = MethodOfPayment.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    methodOfPayments = MethodOfPayment.new(method_of_payment_parameters)
    if methodOfPayments.save
      flash[:notice] = "Se ha creado correctamente el proveedor."
      redirect_to :action => :index
    else
      #"Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      methodOfPayments.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @methodOfPayments = methodOfPayments
      render :new, layout: false
    end
        
  end

  def edit
    @methodOfPayments = MethodOfPayment.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    flash[:error] = nil
    methodOfPayments = MethodOfPayment.find(params[:id])
    if methodOfPayments.update_attributes(method_of_payment_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      methodOfPayments.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @methodOfPayments = methodOfPayments
      render :edit, layout: false
    end
  end

  def destroy
    methodOfPayments = MethodOfPayment.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => methodOfPayments
  end

  def save
    if valid?
      #save method implementation
      true
    else
      false
    end
  end

  private
  def method_of_payment_parameters
    params.require(:method_of_payment).permit(:name, :symbol)
  end
end
