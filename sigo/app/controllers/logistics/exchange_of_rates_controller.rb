class Logistics::ExchangeOfRatesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  def index
    flash[:error] = nil
    @ExchangeOfRates = ExchangeOfRate.all
    render layout: false
  end

  def show
    render :json => nil
  end

  def new
    @ExchangeOfRates = ExchangeOfRate.new
    @moneys = Money.all
    @today = DateTime.now.strftime("%d/%m/%Y")
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    x = ExchangeOfRate.new(eor_parameters)
    x.day = DateTime.now
    if x.save
      flash[:notice] = "Se ha creado correctamente el tipo de cambio."
      redirect_to :action => :index
    else
      #"Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      x.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @ExchangeOfRates = x
      @moneys = Money.all
      @today = DateTime.now.strftime("%d/%m/%Y")
      render :new, layout: false
    end
  end

  def edit
    @ExchangeOfRates = ExchangeOfRate.find(params[:id])
    @moneys = Money.all
    @today = @ExchangeOfRates.day.strftime("%d/%m/%Y")
    @action = 'edit'
    render layout: false
  end

  def update
    flash[:error] = nil
    x = ExchangeOfRate.find(params[:id])
    if x.update_attributes(eor_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      x.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @ExchangeOfRates = x
      @moneys = Money.all
      @today = DateTime.now.strftime("%d/%m/%Y")
      render :edit, layout: false
    end
  end

  def destroy
    x = ExchangeOfRate.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => x
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
  def eor_parameters
    params.require(:exchange_of_rate).permit(:day, :money_id, :value)
  end
end
