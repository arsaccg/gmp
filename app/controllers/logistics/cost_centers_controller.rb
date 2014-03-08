class Logistics::CostCentersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  def index
    @costCenters = CostCenter.all
    if params[:task] == 'created' || params[:task] == 'edited'
      render layout: 'dashboard'
    else
      render layout: false
    end
  end

  def show

  end

  def new
    @costCenter = CostCenter.new
    render :new, layout: false
  end

  def create
    costCenter = CostCenter.new(cost_center_parameters)
    if costCenter.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      render layout: false
    end      
  end

  def edit
    @costCenter = CostCenter.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    cost_center = CostCenter.find(params[:id])
    cost_center.update_attributes(cost_center_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index
  end

  def destroy
    cost_center = CostCenter.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => cost_center
  end

  private
  def cost_center_parameters
    params.require(:cost_center).permit(:code, :name)
  end

end