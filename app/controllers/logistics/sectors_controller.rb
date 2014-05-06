class Logistics::SectorsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  def index
    flash[:error] = nil
    @Sectors = Sector.where("code LIKE '__'")
    render layout: false
  end

  def create
    if params[:is]['subsector'] == nil
      sector = Sector.new(sector_parameters)
    else
      sector = Sector.new
      sector.code = params[:extrafield]['first_code'].to_s + params[:sector]['code'].to_s
      sector.name = params[:sector]['name'].to_s
    end

    if sector.save
      flash[:notice] = "Se ha creado correctamente el sector."
      redirect_to :action => :index
    else
      sector.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @Sectors = sector
      render :new, layout: false
    end
  end

  def edit
    @Sectors = Sector.find(params[:id])
    if params[:subsector]
      @subsector = true
      @sectors = Sector.where("`code` LIKE  '__'")
    end
    @action = 'edit'
    render layout: false
  end

  def show
    sector = Sector.find(params[:id])
    render :show
  end

  def update
    sector = Sector.find(params[:id])
    if params[:is]['subsector'] == nil
      if sector.update_attributes(sector_parameters)
        flash[:notice] = "Se ha actualizado correctamente los datos."
        redirect_to :action => :index
      else
        sector.errors.messages.each do |attribute, error|
          flash[:error] =  flash[:error].to_s + error.to_s + "  "
        end
        # Load new()
        @Sectors = sector
        render :edit, layout: false
      end
    else
      sector.code = params[:extrafield]['first_code'].to_s + params[:sector]['code'].to_s
      sector.name = params[:sector]['name'].to_s
      if sector.save
        flash[:notice] = "Se ha actualizado correctamente los datos."
        redirect_to :action => :index
      else
        sector.errors.messages.each do |attribute, error|
          flash[:error] =  flash[:error].to_s + error.to_s + "  "
        end
        # Load new()
        @Sectors = sector
        render :edit, layout: false
      end
    end
  end

  def new
    @Sectors = Sector.new
    if params[:subsector]
      @subsector = true
      @sectors = Sector.where("`code` LIKE  '__'")
    end
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
