class Management::ExtensionscontrolsController < ApplicationController
  #before_filter :authorize_manager
  before_filter :authenticate_user!

  def index
    @extensionscontrol = Extensionscontrol.where(:cost_center_id => get_company_cost_center('cost_center')) 
    #@project = CostCenter.find(get_company_cost_center('cost_center'))
    @cost_center_detail = CostCenterDetail.where(cost_center_id: get_company_cost_center('cost_center'))[0]
    
    @aditional_term = 0
    @extensionscontrol.each do |ec|
      @aditional_term += ec.approved_deadline
    end

    render :index, :layout => false
  end

  def show
  end

  def create
    extensionscontrol = Extensionscontrol.new(extensions_parameters)
    @project_id = params[:project_id]
    extensionscontrol.status
    extensionscontrol.cost_center_id = @project_id
    extensionscontrol.save
    redirect_to :action => :index, :cost_center_id => @project_id, :layout => false
  end

  def update
  end

  def new
    @extensionscontrol = Extensionscontrol.new
    @project_id = params[:project_id]
    render :new, :layout => false
  end

  def approve
    extensionscontrol = Extensionscontrol.find(params[:extension_id])
    @project_id = params[:project_id]
    extensionscontrol.approve
    redirect_to :action => :index, :project_id => @project_id, :layout => false
  end

  def disprove
    extensionscontrol = Extensionscontrol.find(params[:extension_id])
    @project_id = params[:project_id]
    extensionscontrol.disprove
    redirect_to :action => :index, :project_id => @project_id, :layout => false
  end

  private
  def extensions_parameters
    params.require(:extensionscontrol).permit(:motive, :requested_deadline, :approved_deadline, :requested_mgg, :approved_mgg, :resolution, :observation, :files, :cost_center_id)
  end

end
