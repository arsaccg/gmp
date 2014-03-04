class Logistics::CostCentersController < ApplicationController
  def index
    @costcenters = CostCenter.all
  end

  def new
    @costcenter = CostCenter.new
  end

  def create
    @costcenter = CostCenter.new(cost_center_parameters)
    if @costcenter.save?
      flash[:notice] = "Se ha creado correctamente el nuevo centro de costos"
      redirect_to :action => :index
    else
      flash[:error] = "Ha ocurrido un problema."
      render :new
    end
  end

  def edit
    @costcenter = CostCenter.find(params[:id])
    
  end

  def update
    @costcenter = CostCenter.find(params[:id])
    @costcenter.update_attributes(cost_center_parameters)

  end

  def show
    @costcenter = CostCenter.find(params[:id])
  end

  def destroy
  end

  private
  def cost_center_parameters
    params.require(:cost_center).permit(:name)
  end

end
