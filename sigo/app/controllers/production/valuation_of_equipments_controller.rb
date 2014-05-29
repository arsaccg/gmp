class Production::ValuationOfEquipmentsController < ApplicationController
	def index
		@company = get_company_cost_center('company')
  	#@workingGroups = WorkingGroup.all
    @subcontractequipmentdetail = SubcontractEquipmentDetail.all
    render layout: false
	end
	def new
		@costCenter = CostCenter.new
		TypeEntity.where("name LIKE '%Proveedores%'").each do |executor|
	      @executors = executor.entities
	    end
		render layout: false
	end

	def get_report
		@cad = Array.new
    @start_date = params[:start_date]
    @end_date = params[:end_date]
		@subcontractequipment = SubcontractEquipment.find_by_entity_id(params[:executor])
		@working_group = WorkingGroup.where("executor_id LIKE ?", params[:executor])
		@numbercode = 1
    @subadvances = 0
    @fuel_discount = 0
    @initial_amortization_percent = 0
    @accumulated_fuel_discount = 0
    @accumulated_amortizaciondeadelanto = 0
    @totalprice = 0
    @bill = 0
		@subcontractequipment.subcontract_equipment_advances.each do |subadvances|
      @subadvances+=subadvances.advance
    end
    if @subcontractequipment.initial_amortization_percent != nil
      @initial_amortization_percent = @subcontractequipment.initial_amortization_percent
    end
    if @working_group.present?
      @working_group.each do |wg|
        @cad << wg.id
      end
      @cad = @cad.join(',')
    else
      @cad = '0'
    end
    @workers_array3 = business_days_array3(@start_date, @end_date, @cad)
    @workers_array3.each do |workerDetail|
      @totalprice += workerDetail[4]
    end
    @balance = @subadvances + @accumulated_amortizaciondeadelanto
    @bill = @totalprice-@subcontractequipment.initial_amortization_number
    @billigv = @bill*0.18
    @numbercode = @numbercode.to_s.rjust(3,'0')
    render(partial: 'report_table', :layout => false)
  end

  def business_days_array3(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT  art.name, 
      uom.name, 
      SUM( poed.effective_hours ), 
      si.price, 
      si.price*SUM( poed.effective_hours) 
      FROM part_of_equipments poe, part_of_equipment_details poed, articles art, unit_of_measurements uom, subcontract_inputs si
      WHERE poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND poe.id=poed.part_of_equipment_id
      AND poe.equipment_id=art.id
      AND poe.equipment_id=si.article_id
      AND uom.id = art.unit_of_measurement_id
      AND poed.working_group_id IN(" + working_group_id + ")
      GROUP BY art.name
    ")
    return workers_array3
  end
end