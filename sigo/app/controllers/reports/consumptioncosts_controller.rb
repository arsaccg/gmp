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
    @month = Date.parse(params[:date] + '-01').strftime('%B %Y')
  	cost_center_obj = CostCenter.find(get_company_cost_center('cost_center'))
  	@cost_center_str = cost_center_obj.company.name.to_s + ': ' + ' CC ' + cost_center_obj.code.to_s + ' - ' + cost_center_obj.name.to_s
  	@magic_result_ge = ConsumptionCost.apply_all_consult
    @magic_result_gen_serv = ConsumptionCost.apply_all_gen_serv
  	render(partial: 'table', :layout => false)
  end

  def create_tables_missing
    cost_centers = CostCenter.all
    cost_centers.each do |cc|
      create_tables = ConsumptionCost.create_tables_new_costcenter(cc.id,cc.start_date,cc.end_date)
    end
    flash[:notice] = "Se han creado las tablas de los centros de costo."
    redirect_to :action => :index
  end
end
