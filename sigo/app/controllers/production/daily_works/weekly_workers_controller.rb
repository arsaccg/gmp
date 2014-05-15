class Production::DailyWorks::WeeklyWorkersController < ApplicationController
  def index
  	@workingGroups = WorkingGroup.all
  	render layout: false
  end

  def search_weekly_work
  	@company = params[:company_id]
  	@working_group = params[:working_group]
  	@start_date = params[:start_date]
  	@end_date = params[:end_date]
	render(partial: 'weekly_table', :layout => false)
  end

end
