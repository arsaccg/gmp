class Logistics::BanksController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @banks = Bank.all
    render layout: false
  end

  def create
    flash[:error] = nil
    bank = Bank.new(bank_parameters)
    if bank.save
      #"Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      bank.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      redirect_to :action => :index
    else
      bank.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @bank = bank
      render :new, layout: false
    end

  end

  def edit
    @bank = Bank.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def show
    flash[:error] = nil
    @bank = Bank.find(params[:id])
    render :show
  end

  def update
    flash[:error] = nil
    bank = Bank.find(params[:id])
    if bank.update_attributes(bank_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      bank.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @bank = bank
      render :edit, layout: false
    end
  end

  def new
    @bank = Bank.new
    render :new, layout: false
  end

  def destroy
    bank = Bank.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el banco seleccionado."
    render :json => bank
  end

  private
  def bank_parameters
    params.require(:bank).permit(:business_name, :ruc)
  end
end
