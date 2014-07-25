class Administration::HealthCentersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @healthcenter = HealthCenter.all
    @company = session[:company]
    render layout: false
  end

  def show
    @healthcenter = HealthCenter.find(params[:id])
    render layout: false
  end

  def new
    @healthcenter = HealthCenter.new 
    @today = Time.now
    render layout: false
  end

  def create
    flash[:error] = nil
    healthcenter = HealthCenter.new(healthcenter_parameters)
    if healthcenter.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      healthcenter.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @healthcenter = healthcenter
      render :new, layout: false 
    end
  end

  def edit
    @healthcenter = HealthCenter.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    flash[:error] = nil
    healthcenter = HealthCenter.find(params[:id])
    if healthcenter.update_attributes(healthcenter_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      healthcenter.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @healthcenter = healthcenter
      render :edit, layout: false
    end
  end

  def destroy
    healthcenter = HealthCenter.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el centro de salud seleccionado."
    render :json => healthcenter
  end

  private
  def healthcenter_parameters
    params.require(:health_center).permit(:enterprise)
  end
end