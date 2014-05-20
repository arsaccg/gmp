class Management::ExtensionscontrolsController < ApplicationController
  before_filter :authorize_manager

  def index
    @extensionscontrol = Extensionscontrol.where(:project_id => params[:project_id])
    @project = Project.find(params[:project_id])
    render :index, :layout => false
  end

  def show
  end

  def create
    extensionscontrol = Extensionscontrol.new(extensions_parameters)
    @project_id = params[:project_id]
    extensionscontrol.status
    extensionscontrol.project_id = @project_id
    extensionscontrol.save
    redirect_to :action => :index, :project_id => @project_id, :layout => false
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
    params.require(:extensionscontrol).permit(:motive, :requested_deadline, :approved_deadline, :requested_mgg, :approved_mgg, :resolution, :observation, :files)
  end

end