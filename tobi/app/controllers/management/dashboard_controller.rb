class Management::DashboardController < ApplicationController
  before_filter :authenticate_manager!

  layout "dashboard"

  def index
    @user = current_manager
    #if @user == nil
    #  redirect_to :controller => "management/budgets", :action => :administrate_budget
    #end

    #@type_user = @user.kind

  	project_id = params['project']
  	@project_selected = CostCenter.find(project_id).to_json

  	@project = CostCenter.find(project_id)	
  	
  	@budget_sale = Budget.where("`type_of_budget` = 1 AND `subbudget_code` IS NOT NULL AND `cost_center_id` = (?)", project_id).first.id rescue nil
  	@budget_goal = Budget.where("`type_of_budget` = 2 AND `cost_center_id` = (?)", project_id).first.id rescue @budget_sale
    
    p "========================== T-T ========================="
    p 'budget_sale'
    p @budget_sale
    p 'budget_goal'
    p @budget_goal
    p "========================== T-T ========================="
  	render :index
  end

end
