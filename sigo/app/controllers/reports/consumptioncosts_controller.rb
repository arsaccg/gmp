class Reports::ConsumptioncostsController < ApplicationController
  def index
  	@dates = Array.new
  	cost_center_detail_obj = CostCenter.find(get_company_cost_center('cost_center')).cost_center_detail
  	start_date = cost_center_detail_obj.start_date_of_work
  	end_date = start_date + cost_center_detail_obj.execution_term.days
  	start_date.upto(end_date) do |a|
  		@dates << [a.month, a.year]
  	end
  	@dates.uniq!
  	render layout: false
  end

  def consult
  	cost_center_obj = CostCenter.find(get_company_cost_center('cost_center'))
  	@cost_center_str = cost_center_obj.company.name.to_s + ': ' + ' CC ' + cost_center_obj.code.to_s + ' - ' + cost_center_obj.name.to_s
  	render(partial: 'table', :layout => false)
  end
end
