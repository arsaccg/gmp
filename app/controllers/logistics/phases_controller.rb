class Logistics::PhasesController < ApplicationController
  def index
    @phases = Phase.all
    if params[:task] == 'created' || params[:task] == 'edited' || params[:task] == 'failed' || params[:task] == 'deleted'
      render layout: 'dashboard'
    else
      render layout: false
    end
  end

  def create
    phase = Phase.new(phase_parameters)
    if phase.save
      flash[:notice] = "Se ha creado correctamente la nueva fase."
      redirect_to :action => :index, :task => 'created'
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => :index, :task => 'failed'
    end
  end

  def edit
    @phase = Phase.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def show
    phase = Phase.find(params[:id])
    render :show
  end

  def update
    phase = Phase.find(params[:id])
    phase.update_attributes(phase_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index, :task => 'edited'
  end

  def new
    @phase = Phase.new
    render layout: false
  end

  def destroy
    phase = Phase.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente la fase seleccionado."
    redirect_to :action => :index, :task => 'deleted'
  end

  private
  def phase_parameters
    params.require(:phase).permit(:code, :name, :category)
  end
end
