class Logistics::CostCentersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  def index
    flash[:error] = nil
    if params[:company_id] != nil
      @company = params[:company_id]
    else
      # After Update: Cache -> company_id
      cache = ActiveSupport::Cache::MemoryStore.new()
      @company = Rails.cache.read('company_id')
    end
    #@own_cost_center = current_user.cost_centers
    @costCenters = CostCenter.where(company_id: "#{@company}")
    render layout: false
  end

  def show
    render :json => nil
  end

  def new
    @costCenter = CostCenter.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    costCenter = CostCenter.new(cost_center_parameters)
    if costCenter.save
      flash[:notice] = "Se ha creado correctamente el centro de costo."
      redirect_to :action => :index, company_id: params[:cost_center]['company_id']
    else
      #"Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      costCenter.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @costCenter = costCenter
      render :new, layout: false
    end
        
  end

  def edit
    @costCenter = CostCenter.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    flash[:error] = nil
    costCenter = CostCenter.find(params[:id])

    # Cache -> company_id, becouse after save redirect to Index
    cache = ActiveSupport::Cache::MemoryStore.new(expires_in: 1.minutes)
    Rails.cache.write('company_id', costCenter.company_id)

    if params[:timeline] == nil
      # Save Maintenance
      if costCenter.update_attributes(cost_center_parameters)
        flash[:notice] = "Se ha actualizado correctamente los datos."
        redirect_to :action => :index
      else
        costCenter.errors.messages.each do |attribute, error|
          flash[:error] =  flash[:error].to_s + error.to_s + "  "
        end
        @costCenter = costCenter
        render :edit, layout: false
      end
    else
      # Save TimeLine by Start Date / End Date
      if costCenter.update_attributes(cost_center_parameters_timeline)
        CostCenterTimeline.LoadTimeLine(costCenter.id, costCenter.start_date, costCenter.end_date)

        flash[:notice] = "Se actualizó la duración del proyecto."
        redirect_to :action => :index
      else
        costCenter.errors.messages.each do |attribute, error|
          flash[:error] =  flash[:error].to_s + error.to_s + "  "
        end
        @costCenter = costCenter
        render :edit, layout: false
      end
    end
  end

  def destroy
    flash[:error] = nil
    costCenter = CostCenter.find(params[:id])
    if costCenter.update_attributes({status: "D"})#, user_updates_id: params[:current_user_id]})
      flash[:notice] = "Se ha eliminado correctamente."
      render :json => {notice: flash[:notice]}
    else
      costCenter.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @costCenter = costCenter
      render :json => {error: flash[:error]}
    end
  end

  def save
    if valid?
      #save method implementation
      true
    else
      false
    end
  end

  def update_timeline
    @costCenter = CostCenter.find(params[:id])
    @costCenterTimeLine = CostCenterTimeline.where("cost_center_id =" + @costCenter.id.to_s)
    
    render(partial: 'form_timeline', :layout => false)
  end

  def select_warehouses
    @select = CostCenter.find(params[:id]).warehouses
    
    render(partial: 'select', :layout => false)
  end

  private
  def cost_center_parameters
    params.require(:cost_center).permit(:code, :name, :company_id)
  end

  def cost_center_parameters_timeline
    params.require(:cost_center).permit(:start_date, :end_date)
  end

end