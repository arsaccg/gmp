class Logistics::SectorsController < ApplicationController
  before_filter :authenticate_user!
  #skip_before_filter :verify_authenticity_token, :only => :create
  #protect_from_forgery with: :null_session, :only => [:index, :show, :create]
  def index
    @Sectors = Sector.all
    if params[:task] == 'created' || params[:task] == 'edited' || params[:task] == 'failed' || params[:task] == 'deleted'
      render layout: 'dashboard'
    else
      render layout: false
    end
  end

  def create
    sector = Sector.new(sector_parameters)
    if sector.save
      flash[:notice] = "Se ha creado correctamente la nueva unidad de medida."
      redirect_to :action => :index
    else
      flash[:error] = "Ha ocurrido un problema. "
      render layout: false
    end
  end

  def edit
    @Sectors = Sector.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def show
    sector = Sector.find(params[:id])
    render :show
  end

  def update
    sector = Sector.find(params[:id])
    sector.update_attributes(sector_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index
  end

  def new
    @Sectors = Sector.new
    render :new, layout: false
  end

  def destroy
    sector = Sector.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el sector seleccionado."
    redirect_to :action => :index
  end

  private
  def sector_parameters
    params.require(:sector).permit(:name)
  end
end
