class Logistics::SubphasesController < ApplicationController
  #before_filter :authenticate_user!
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  def index
  end

  def new
    @subphase = Phase.new
    @phases = Phase.all.where(category: 'phase')
    @action = 'create'
    render :new, layout: false
  end

  def create
    subphase = Phase.new(subphase_parameters)
    subphase.code = params[:extra_field]['first_code'].to_s + params[:phase]['code'].to_s
    if subphase.save
      flash[:notice] = "Se ha creado correctamente la nueva subfase."
      redirect_to url_for(:controller => :phases, :action => :index)
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      render layout: false
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
    subphase.category = "subphase"
    subphase.code = params[:extrafield]['first_code'].to_s + params[:phase]['code'].to_s
    subphase.name = params[:phase]['name'].to_s
    subphase.save #update_attributes(subphase_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to url_for(:controller => :phases, :action => :index)
  end

  def destroy
    subphase = Phase.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente la subfase seleccionado."
    render :json => subphase
    #redirect_to :action => :index, :task => 'deleted'
  end

  private
  def subphase_parameters
    params.require(:phase).permit(:code, :name, :category)
  end
end
