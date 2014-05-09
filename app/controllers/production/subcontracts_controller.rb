class Production::SubcontractsController < ApplicationController
  def index
    # General
    @company = params[:company_id]
    @type = params[:type]

    @subcontracts = Subcontract.all
    render layout: false
  end

  def show
    @subcontract = Subcontract.find(params[:id])
    render layout: false
  end

  def new
    @subcontract = Subcontract.new
    TypeEntity.where("name LIKE '%Proveedores%'").each do |supply|
      @suppliers = supply.entities
    end
    @company = params[:company_id]
    render layout: false
  end

  def create
    subcontract = Subcontract.new(working_groups_parameters)
    if subcontract.save
      flash[:notice] = "Se ha creado correctamente el trabajador."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      subcontract.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def edit
    @subcontract = Subcontract.find(params[:id])
    @company = params[:company_id]
    render layout: false
  end

  def update
    subcontract = Subcontract.find(params[:id])
    if subcontract.update_attributes(working_groups_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      subcontract.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @subcontract = subcontract
      render :edit, layout: false
    end
  end

  def destroy
    subcontract = Subcontract.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el Grupo de Trabajo."
    render :json => subcontract
  end

  private
  def subcontracts_parameters
    params.require(:subcontract).permit(:entity_id, :valorization, :terms_of_payment, :initial_amortization_number, :initial_amortization_percent, :guarantee_fund, :detraction, :contract_amount, :type)
  end
end
