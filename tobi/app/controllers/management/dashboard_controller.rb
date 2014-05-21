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

  	@project = Project.find(project_id)	
  	
  	@budget_sale = Budget.where("`type_of_budget` = 1 AND `subbudget_code` IS NOT NULL AND `project_id` = (?)", project_id).first.id rescue nil
  	@budget_goal = Budget.where("`type_of_budget` = 2 AND `project_id` = (?)", project_id).first.id rescue nil

  	render :index
  end

end
