class Logistics::MoneyController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  def index
    flash[:error] = nil
    @moneys = Money.all
    @ex = ExchangeOfRate.all
    render layout: false
  end

  def show
    render :json => nil
  end

  def new
    @moneys = Money.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    moneys = Money.new(money_parameters)
    if moneys.save
      flash[:notice] = "Se ha creado correctamente la moneda."
      redirect_to :action => :index
    else
      #"Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      moneys.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @moneys = moneys
      render :new, layout: false
    end
        
  end

  def edit
    @moneys = Money.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    flash[:error] = nil
    moneys = Money.find(params[:id])
    if moneys.update_attributes(money_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      moneys.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @moneys = moneys
      render :edit, layout: false
    end
  end

  def destroy
    moneys = Money.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => moneys
  end

  def save
    if valid?
      #save method implementation
      true
    else
      false
    end
  end

  def add_exchange_of_rate
    @ExchangeOfRate = ExchangeOfRate.new
    @moneys = Money.all
    render :partial => 'neweor', layout: false
  end

  private
  def money_parameters
    params.require(:money).permit(:name, :symbol)
  end
end
