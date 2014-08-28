class Production::MachineryReportsController < ApplicationController
	def index
		@company = get_company_cost_center('company')
    @cost_center=session[:cost_center]
  	#@workingGroups = WorkingGroup.all
    @subcontractequipmentdetail = SubcontractEquipmentDetail.all
    render layout: false
	end

	def get_report
		@totaldif = 0
    @totaltotalhours = 0
    @totalfuel_amount = 0
    @result = Array.new
    @result = params[:subcontractequipment]
		start_date = params[:start_date]
    end_date = params[:end_date]
		@poe_array = poe_array(start_date, end_date, @result)
    @poe_array.each do |workerDetail|
      @totaldif += workerDetail[4].to_f.round(2)
      @totaltotalhours += workerDetail[5].to_f.round(2)
      @totalfuel_amount += workerDetail[7].to_f.round(2)
      puts @totaldif.inspect
    end
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
  
	def poe_array(start_date, end_date, sub_equipment_id)
    @name = get_company_cost_center('cost_center')
    poe_array = ActiveRecord::Base.connection.execute("
      SELECT poe.code, poe.date, poe.initial_km, poe.final_km, poe.dif, SUM(poe.total_hours), art.name, SUM(poe.fuel_amount)
      FROM part_of_equipments poe, articles_from_cost_center_" + @name.to_s + " art, subcontract_equipments sce
      WHERE poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND sce.id=poe.subcontract_equipment_id
      AND poe.subcategory_id=art.id
      AND poe.equipment_id IN(" + sub_equipment_id + ")
      GROUP BY poe.code
      ORDER BY poe.date
    ")
    return poe_array
  end

end