class Libraries::DownloadSoftwaresController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @soft = DownloadSoftware.where("type_of_cost_center LIKE '"+CostCenter.find(get_company_cost_center('cost_center')).speciality.to_s+"'")
    render layout: false
  end

  def show
    @soft = DownloadSoftware.find(params[:id])
    render layout: false
  end

  def new
    @soft = DownloadSoftware.new
    render layout: false
  end

  def create
    flash[:error] = nil
    soft = DownloadSoftware.new(soft_parameters)
    if soft.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      soft.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @soft = soft
      render :new, layout: false 
    end
  end

  def edit
    @soft = DownloadSoftware.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    soft = DownloadSoftware.find(params[:id])
    if soft.update_attributes(soft_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      soft.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @soft = soft
      render :edit, layout: false
    end
  end

  def destroy
    soft = DownloadSoftware.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => soft
  end

  private
  def soft_parameters
    params.require(:download_software).permit(:name, :description, :file,:type_of_cost_center)
  end
end