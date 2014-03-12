class Logistics::SectorsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
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
      flash[:notice] = "Se ha creado correctamente el sector."
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
    render :json => sector
    #redirect_to :action => :index
  end

  private
  def sector_parameters
    params.require(:sector).permit(:name, :code)
  end
end
