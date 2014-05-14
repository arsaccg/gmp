class Management::ProjectsController < ApplicationController
  #before_filter :authorize_manager, :except => :index
  before_filter :authenticate_manager!
  layout "dashboard"

  def index

  	@projects = Project.where("deleted != ?", '1')

  end

  def edit
    @project = Project.find(params[:id])
    
    render :edit, layout: false
  end


  def new
  	@project = Project.new
  	render :new, layout: false
  end

  def show
  	@project = Project.find(params[:id])
    
  	render :show, layout: false
  end

  def create
  	project = Project.new(project_parameters)
    wbsitem = Wbsitem.new


  	#if project.save
  	project.save
    wbsitem.codewbs = project.id
    wbsitem.name = project.name
    wbsitem.project_id = project.id
    wbsitem.save
  	redirect_to :action => :index
  end

  def update
    @project = Project.find(params[:id])

    @project.update_attributes(project_parameters)

    @project.save
    
    render :show, layout: false
  end

  def destroy
  	project = Project.find(params[:id])
  	project.deleted="1"
  	project.save
  	redirect_to :action => :index
  end

  private
  def project_parameters
    params.require(:project).permit(:name, :total_amount, :direct_cost_amount, :general_cost_amount, :utility_amount, :advance_payment_percent, :coaching_granted_percent, :igv)
  end

end
