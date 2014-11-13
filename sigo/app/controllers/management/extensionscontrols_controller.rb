class Management::ExtensionscontrolsController < ApplicationController
  #before_filter :authorize_manager
  before_filter :authenticate_user!, :only => [:index, :shoe, :create, :update, :new, :approve, :disprove ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
    

  def index
    @extensionscontrol = Extensionscontrol.where(:cost_center_id => get_company_cost_center('cost_center')) 
    #@project = CostCenter.find(get_company_cost_center('cost_center'))
    @cost_center_detail = CostCenterDetail.where(cost_center_id: get_company_cost_center('cost_center'))[0]
    
    @aditional_term = 0
    @extensionscontrol.each do |ec|
      if ec.status == "approved"
        @aditional_term += ec.approved_deadline
      end
    end

    render :index, :layout => false
  end

  def show
  end

  def create
    extensionscontrol = Extensionscontrol.new(extensions_parameters)
    extensionscontrol.status
    extensionscontrol.cost_center_id = get_company_cost_center('cost_center')
    extensionscontrol.save
    redirect_to :action => :index, :layout => false
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
    @project_id = get_company_cost_center('cost_center')
    extensionscontrol.approve
    redirect_to :action => :index, :project_id => @project_id, :layout => false
  end

  def disprove
    extensionscontrol = Extensionscontrol.find(params[:extension_id])
    @project_id = get_company_cost_center('cost_center')
    extensionscontrol.disprove
    redirect_to :action => :index, :project_id => @project_id, :layout => false
  end

  def destroy
  end

  private
  def extensions_parameters
    params.require(:extensionscontrol).permit(:motive, :requested_deadline, :approved_deadline, :requested_mgg, :approved_mgg, :resolution, :observation, :files, :cost_center_id)
  end

end
