class Production::WeeklyReportsController < ApplicationController
	def index
    @company = get_company_cost_center('company')
    @workingGroups = WorkingGroup.all
    @week = CostCenter.getWeek5(get_company_cost_center('cost_center'),Time.now.to_date.to_s)
    render layout: false
  end

  def get_report
  	@week3 = Array.new
    @cad = Array.new
    @week = CostCenter.getWeek(get_company_cost_center('cost_center'),Time.now.to_date.to_s)
    if @week.count>=10
      @week3 = CostCenter.getWeek3(get_company_cost_center('cost_center'),Time.now.to_date.to_s,10)
      @week3.each do |week3|
        @cad << week3[1] + ' ' + week3[2].strftime("%d/%m") + '-' + week3[3].strftime("%d/%m")
      end
      @cad.reverse!
    else
      @week2 = CostCenter.getWeek2(get_company_cost_center('cost_center'),Time.now.to_date.to_s,10-@week.count)
      @week.each do |week|
        @week3 << week
      end
      @week2.each do |week|
        @week3 << week
      end
      @week3.each do |week3|
        @cad << week3[1] + ' ' + week3[2].strftime("%d/%m") + '-' + week3[3].strftime("%d/%m")
      end
    end
    @result = params[:start_date].split(/,/)
    @article= params[:article]
    start_date = @result[1]
    end_date = @result[2]
    render(partial: 'report_table', :layout => false)
  end
end