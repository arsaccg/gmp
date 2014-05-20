class Production::DailyWorks::WeeklyWorkersController < ApplicationController
  def index
  	@workingGroups = WorkingGroup.all
  	render layout: false
  end
end
