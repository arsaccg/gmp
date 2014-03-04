class Logistics::CostCentersController < ApplicationController
<<<<<<< HEAD
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
=======
  before_filter :authenticate_user!
  def index
    @costCenters = CostCenter.all
    if params[:task] == 'created' || params[:task] == 'edited'
      render layout: 'dashboard'
    else
      render layout: false
    end
  end

  def create
    costCenter = CostCenter.new(cost_center_parameters)
    if costCenter.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index, :task => 'created'
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

  def show

  end

  def update
    cost_center = CostCenter.find(params[:id])
    cost_center.update_attributes(cost_center_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index, :task => 'edited'
  end

  def new
    @costCenter = CostCenter.new
    render :new, layout: false
  end

  def destroy
    cost_center = CostCenter.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    redirect_to :action => :index, :task => 'deleted'
>>>>>>> 011f18f2cde719433daf750feba7edcf41f7938a
  end

  private
  def cost_center_parameters
    params.require(:cost_center).permit(:name)
  end

end
