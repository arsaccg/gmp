# encoding: utf-8
class Logistics::FinancialVariablesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    flash[:error] = nil
    @financialVariable = FinancialVariable.all
    render layout: false
  end

  def new
    @financialVariable = FinancialVariable.new
    render :new, layout: false
  end

  def create
    financialVariable = FinancialVariable.new(financial_variables_parameters)
    if financialVariable.save
      flash[:notice] = "Se ha creado correctamente la variable."
      redirect_to :action => :index
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => :index
    end
  end

  def edit
    @financialVariable = FinancialVariable.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    financialVariable = FinancialVariable.find(params[:id])
    financialVariable.update_attributes(financial_variables_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index
  end

  def show
  end

  def destroy
    financialVariable = FinancialVariable.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => financialVariable
  end

  private
  def financial_variables_parameters
    params.require(:financial_variable).permit(:name, :value)
  end
end