class Logistics::PhasesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @phases = Phase.where("category LIKE 'phase'")
    if params[:task] == 'created' || params[:task] == 'edited' || params[:task] == 'failed' || params[:task] == 'deleted'
      render layout: 'dashboard'
    else
      render layout: false
    end
  end

  def create
    phase = Phase.new(phase_parameters)
    if phase.category == "subphase"
      phase.code = params[:extrafield]['first_code'].to_s + params[:phase]['code'].to_s
    end
    if phase.save
      flash[:notice] = "Se ha creado correctamente la nueva fase."
      redirect_to :action => :index
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      render layout: false
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
    if phase.category == "subphase"
      params[:phase]['code'] = params[:extrafield]['first_code'].to_s + params[:phase]['code'].to_s
    end
    phase.update_attributes(phase_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index
  end

  def new
    @phase = Phase.new
    render layout: false
  end

  def destroy
    phase = Phase.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente la fase seleccionado."
    render :json => phase
    #redirect_to :action => :index, :task => 'deleted'
  end

  private
  def phase_parameters
    params.require(:phase).permit(:code, :name, :category)
  end
end
