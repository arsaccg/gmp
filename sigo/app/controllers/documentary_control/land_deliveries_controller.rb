class DocumentaryControl::LandDeliveriesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @type_land = TypeOfLandDelivery.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    @land = LandDelivery.find(params[:id])
    render layout: false
  end

  def new
    @cost_center = get_company_cost_center('cost_center')
    @type_land = TypeOfLandDelivery.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    @land = LandDelivery.new
    render layout: false
  end

  def create
    flash[:error] = nil
    land = LandDelivery.new(land_parameters)
    land.cost_center_id = get_company_cost_center('cost_center')
    if land.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      land.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @land = land
      render :new, layout: false 
    end
  end

  def edit
    @land = LandDelivery.find(params[:id])
    @cost_center = get_company_cost_center('cost_center')
    @type_land = TypeOfLandDelivery.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    @action = 'edit'
    render layout: false
  end

  def update
    land = LandDelivery.find(params[:id])
    if land.update_attributes(land_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      land.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @land = land
      render :edit, layout: false
    end
  end

  def destroy
    land = LandDelivery.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => land
  end

  def land_works
    word = params[:wordtosearch]
    @land = LandDelivery.where('name LIKE "%'+word.to_s+'%" OR description LIKE "%'+word.to_s+'%" AND cost_center_id = ?', get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  private
  def land_parameters
    params.require(:land_delivery).permit(:name, :description, :document, :type_of_land_delivery_id)
  end
end