class Management::SectorsController < ApplicationController
  
  before_filter :authorize_manager

  def index 

  end

  def edit

  end

  def show

  end

  def update

  end

  def new

  end

  def set_sectors_by_cost_center
  	@cost_center = CostCenter.find(params[:project_id])
  	@sector = @cost_center.sectors.where("LENGTH(code) > 2") rescue []
    @budgets = @cost_center.budgets.where(type_of_budget: 0)
  	 
  	render 'set_sectors_by_cost_center', layout: false
  end



end
