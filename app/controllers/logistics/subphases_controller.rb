class Logistics::SubphasesController < ApplicationController
  def index
  end

  def new
    @subphase = Phase.new
    @phases = Phase.all.where(category: 'phase')
    render layout: false
  end

  def create
    subphase = Phase.new(subphase_parameters)
    if subphase.save
      flash[:notice] = "Se ha creado correctamente la nueva subfase."
      redirect_to url_for(:controller => :phases, :action => :index, :task => 'created')
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to url_for(:controller => :phases, :action => :index, :task => 'failed')
    end
  end

  def edit
    @subphase = Phase.find(params[:id])
    @phases = Phase.all.where(category: 'phase')
    @action = 'edit'
    render layout: false
  end

  def update
    subphase = Phase.find(params[:id])
    subphase.update_attributes(subphase_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to url_for(:controller => :phases, :action => :index, :task => 'edited')
  end

  def destroy
    subphase = Phase.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente la subfase seleccionado."
    redirect_to :action => :index, :task => 'deleted'
  end

  private
  def subphase_parameters
    params.require(:phase).permit(:code, :name, :category)
  end
end
