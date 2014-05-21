class Management::CostCentersController < ApplicationController
  before_filter :authenticate_manager!
  layout "dashboard"
  
  def index
  	@costcenters = CostCenter.where("deleted != ?", '1')
  end
  
  def edit
    @costcenter = CostCenter.find(params[:id])
    render :edit, layout: false
  end
  
  def new
  	@costcenter = CostCenter.new
  	render :new, layout: false
  end

  def show
  	@costcenter = CostCenter.find(params[:id])
  	render :show, layout: false
  end

  def create
  	costcenter = CostCenter.new(cost_center_parameters)
    wbsitem = Wbsitem.new

  	#if project.save
  	costcenter.save
    wbsitem.codewbs = costcenter.id
    wbsitem.name = costcenter.name
    wbsitem.cost_center_id = costcenter.id
    wbsitem.save
  	redirect_to :action => :index
  end

  def update
    @costcenter = CostCenter.find(params[:id])
    @costcenter.update_attributes(cost_center_parameters)
    @costcenter.save
    render :show, layout: false
  end

  def destroy
  	costcenter = CostCenter.find(params[:id])
  	costcenter.deleted="1"
  	costcenter.save
  	redirect_to :action => :index
  end

  private
  def cost_center_parameters
    params.require(:cost_center).permit(:name, :total_amount, :direct_cost_amount, :general_cost_amount, :utility_amount, :advance_payment_percent, :coaching_granted_percent, :igv)
  end
end
