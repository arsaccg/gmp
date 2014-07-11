class DocumentaryControl::PhotoOfWorksController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @photo = PhotoOfWork.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    @photo = PhotoOfWork.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def new
    @cost_center = get_company_cost_center('cost_center')
    @photo = PhotoOfWork.new
    render layout: false
  end

  def create
    flash[:error] = nil
    photo = PhotoOfWork.new(photo_parameters)
    photo.cost_center_id = get_company_cost_center('cost_center')
    if photo.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      photo.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @photo = photo
      render :new, layout: false 
    end
  end

  def edit
    @photo = PhotoOfWork.find(params[:id])
    @cost_center = get_company_cost_center('cost_center')
    @action = 'edit'
    render layout: false
  end

  def update
    photo = PhotoOfWork.find(params[:id])
    photo.cost_center_id = get_company_cost_center('cost_center')
    if photo.update_attributes(photo_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      photo.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @photo = photo
      render :edit, layout: false
    end
  end

  def destroy
    photo = PhotoOfWork.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => photo
  end

  private
  def photo_parameters
    params.require(:photo_of_work).permit(:name, :description, :photo)
  end
end