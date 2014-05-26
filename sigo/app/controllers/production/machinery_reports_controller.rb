class Production::MachineryReportsController < ApplicationController
	def index
		@company = get_company_cost_center('company')
  	@workingGroups = WorkingGroup.all
    @article = Article.where("type_of_article_id = 3")
    render layout: false
	end

	def get_report
		@cad = Array.new
		@poe_group=PartOfEquipment.where("equipment_id LIKE ?", params[:article])
		start_date = params[:start_date]
    end_date = params[:end_date]
    if @poe_group.present?
      @poe_group.each do |wg|
        @cad << wg.id
      end
      @cad = @cad.join(',')
    else
      @cad = '0'
    end
		@poe_array = poe_array(start_date, end_date, @cad)
		@dias_habiles =  range_business_days(start_date,end_date)
		render(partial: 'report_table', :layout => false)
	end

	def range_business_days(start_date, end_date)
    start_date_var = start_date.to_date
    end_date_var = end_date.to_date
    business_days = []
    while end_date_var >= start_date_var
      business_days << start_date_var
      start_date_var = start_date_var + 1.day
    end
    return business_days
  end

	def poe_array(start_date, end_date, working_group_id)
    poe_array = ActiveRecord::Base.connection.execute("
      SELECT poe.code, poe.date, poe.initial_km, poe.final_km, poe.dif, poe.total_hours, art.name, poe.fuel_amount
			FROM part_of_equipments poe, articles art
			WHERE poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
			AND poe.id IN(" + working_group_id + ")
			AND poe.subcategory_id=art.id
			ORDER BY poe.date
    ")
    return poe_array
  end
end