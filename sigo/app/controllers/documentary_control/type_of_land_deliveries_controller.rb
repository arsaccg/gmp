class DocumentaryControl::TypeOfLandDeliveriesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @typeOfLand = TypeOfLandDelivery.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def new
    @typeOfLand = TypeOfLandDelivery.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    typeOfLand = TypeOfLandDelivery.new(typeOfLand_parameters)
    typeOfLand.cost_center_id = get_company_cost_center('cost_center')
    if typeOfLand.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      typeOfLand.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfLand = typeOfLand
      render :new, layout: false
    end
  end

  def edit
    @typeOfLand = TypeOfLandDelivery.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    typeOfLand = TypeOfLandDelivery.find(params[:id])
    typeOfLand.cost_center_id = get_company_cost_center('cost_center')
    if typeOfLand.update_attributes(typeOfLand_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      typeOfLand.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfLand = typeOfLand
      render :edit, layout: false
    end
  end

  def destroy
    typeOfLand = TypeOfLandDelivery.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => typeOfLand
  end

  private
  def typeOfLand_parameters
    params.require(:type_of_land_delivery).permit(:preffix, :name)
  end
end