class Logistics::WarehousesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  def index
    flash[:error] = nil
    if params[:company_id] != nil
      @company = params[:company_id]
      # Cache -> company_id
      cache = ActiveSupport::Cache::MemoryStore.new(expires_in: 120.minutes)
      Rails.cache.write('company_id', @company)
    else
      @company = Rails.cache.read('company_id')
    end
    #logger.info "@company:" + @company + "."    
    @items = Warehouse.where(company_id: "#{@company}")
    render layout: false
  end

  def show
    render :json => nil
  end

  def new
    @company = Rails.cache.read('company_id')
    @warehouse = Warehouse.new
    @cost_centers = CostCenter.where(company_id: "#{@company}")
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    item = Warehouse.new(item_parameters)
    item.user_inserts_id = current_user.id

    @company = Rails.cache.read('company_id')
    @cost_centers = CostCenter.where(company_id: "#{@company}")
    
    if item.update_attributes(item_parameters)
      flash[:notice] = "Se ha creado correctamente el registro."
      redirect_to :action => :index
    else
      #"Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      item.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @warehouse = item
      render :new, layout: false
    end
        
  end

  def edit
    @warehouse = Warehouse.find(params[:id])
    @company = @warehouse.company_id
    @cost_centers = CostCenter.where(company_id: "#{@company}")
    @action = 'edit'
    render layout: false
  end

  def update
    flash[:error] = nil
    item = Warehouse.find(params[:id])
    item.user_updates_id = current_user.id

    @company = Rails.cache.read('company_id')
    @cost_centers = CostCenter.where(company_id: "#{@company}")

    if item.update_attributes(item_parameters)
      flash[:notice] = "Se ha actualizado correctamente el registro."
      redirect_to :action => :index
    else
      item.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @warehouse = item
      render :edit, layout: false
    end
  end

  def destroy
    flash[:error] = nil
    item = Warehouse.find(params[:id])
    item.update_attributes({status: "D", user_updates_id: params[:current_user_id]})
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => item
  end

  def save
    if valid?
      #save method implementation
      true
    else
      false
    end
  end

  private
  def item_parameters
    params.require(:warehouse).permit(:name, :location, :cost_center_id, :company_id)
  end
end
