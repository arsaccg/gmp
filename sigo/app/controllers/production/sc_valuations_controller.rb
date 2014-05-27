class Production::ScValuationsController < ApplicationController
	def index
		@company = get_company_cost_center('company')
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
    @totalprice = 0
    @totalprice2 = 0
    @totalprice3 = 0
    @subadvances = 0
    @valorizacionsinigv = 0
    @amortizaciondeadelanto = 0
    @amortizaciondeadelantoigv = 0
    @totalfacturar = 0
    @totalfacigv = 0
    @totalincluidoigv = 0
    @retenciones = 0
    @detraccion = 0
    @fondogarantia1 = 0
    @fondogarantia2 = 0
    @descuestoequipos = 0
    @descuentomateriales = 0
    @netoapagar = 0
    @accumulated_valorizacionsinigv = 0
    @accumulated_amortizaciondeadelanto = 0
    @accumulated_totalfacturar = 0
    @accumulated_totalfacigv = 0
    @accumulated_totalincluidoigv = 0
    @accumulated_retenciones = 0
    @accumulated_detraccion = 0
    @accumulated_fondogarantia1 = 0
    @accumulated_fondogarantia2 = 0
    @accumulated_descuestoequipos = 0
    @accumulated_descuentomateriales = 0
    @accumulated_netoapagar = 0
    @cad = Array.new
    @cad2 = Array.new
    @company = params[:company_id]
    @numbercode = 1
    @numbercode = @numbercode.to_s.rjust(3,'0')
    @entity= Entity.find_by_id(params[:executor])
    if params[:executor]=="0"
      @working_group = WorkingGroup.all
    end
    if params[:executor]!="0"
      @working_group = WorkingGroup.where("executor_id LIKE ?", params[:executor])
    end
    @subcontract = Subcontract.find_by_entity_id(params[:executor])
    start_date = params[:start_date]
    end_date = params[:end_date]
    if @working_group.present?
      @working_group.each do |wg|
        @cad << wg.id
      end
      @cad = @cad.join(',')
    else
      @cad = '0'
    end
    @workers_array = business_days_array(start_date, end_date, @cad)
    @workers_array2 = business_days_array2(start_date, end_date, @cad)
    @workers_array3 = business_days_array3(start_date, end_date, @cad)
    @workers_array.each do |workerDetail|
      @totalprice += workerDetail[7] + workerDetail[8] + workerDetail[9]
    end
    @workers_array2.each do |workerDetail|
      @totalprice2 += workerDetail[5]
    end
    @workers_array3.each do |workerDetail|
      @totalprice3 += workerDetail[4]
    end
    @subcontract.subcontract_advances.each do |subadvances|
      @subadvances+=subadvances.advance
    end
    @totalbill= @totalprice2-@subcontract.initial_amortization_number
    @totalbilligv= (@totalprice2-@subcontract.initial_amortization_number)*@subcontract.igv
    @totalbillwigv= @totalbill+@totalbilligv
    @retention=@subcontract.detraction.to_i+@subcontract.guarantee_fund.to_i+@totalprice+@totalprice3
    @accumulated_valorizacionsinigv = @totalprice2+@valorizacionsinigv
    @accumulated_amortizaciondeadelanto = @subcontract.initial_amortization_number+@amortizaciondeadelantoigv
    @accumulated_totalfacturar = @totalbill+@totalfacturar
    @accumulated_totalfacigv = @totalbilligv+@totalfacigv
    @accumulated_totalincluidoigv = @totalbillwigv+@totalincluidoigv
    @accumulated_retenciones = @retention+@retenciones
    @accumulated_detraccion = @subcontract.detraction.to_f+@retenciones
    @accumulated_fondogarantia1 = @subcontract.guarantee_fund.to_f+@fondogarantia1
    @accumulated_fondogarantia2 = @totalprice+@fondogarantia2
    @accumulated_descuestoequipos = @totalprice3+@descuestoequipos
    @accumulated_descuentomateriales = @descuentomateriales
    @accumulated_netoapagar = @netoapagar
    @balance = @subcontract.contract_amount - @subadvances + @accumulated_amortizaciondeadelanto
    render(partial: 'report_table', :layout => false)
  end

  def business_days_array(start_date, end_date, working_group_id)
    workers_array = ActiveRecord::Base.connection.execute("
      SELECT  art.name AS category,
        cow.normal_price,
        cow.he_60_price,
        cow.he_100_price,
        SUM( ppd.normal_hours ) AS normal_hours, 
        SUM( ppd.he_60 ) AS he_60, 
        SUM( ppd.he_100 ) AS he_100, 
        cow.normal_price*SUM( ppd.normal_hours ), 
        cow.he_60_price*SUM( ppd.he_60 ), 
        cow.he_100_price*SUM( ppd.he_100 ),
        uom.name, 
        p.date_of_creation 
      FROM part_people p, unit_of_measurements uom, part_person_details ppd, workers w, category_of_workers cow, articles art
      WHERE p.working_group_id IN(" + working_group_id + ")
      AND p.date_of_creation BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND p.id = ppd.part_person_id
      AND w.article_id = art.id
      AND ppd.worker_id = w.id
      AND w.article_id = cow.article_id
      AND uom.id = art.unit_of_measurement_id
      GROUP BY art.name
    ")
    return workers_array
  end

  def business_days_array2(start_date, end_date, working_group_id)
    workers_array2 = ActiveRecord::Base.connection.execute("
      SELECT  pwd.article_id, 
        art.name, 
        uom.name, 
        SUM( pwd.bill_of_quantitties ), 
        si.price, 
        si.price*SUM( pwd.bill_of_quantitties ), 
        p.date_of_creation 
      FROM part_works p, part_work_details pwd, articles art, unit_of_measurements uom, subcontract_inputs si
      WHERE p.date_of_creation BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND p.working_group_id IN(" + working_group_id + ")
      AND p.id = pwd.part_work_id
      AND pwd.article_id = art.id
      AND pwd.article_id = si.article_id
      AND uom.id = art.unit_of_measurement_id
      GROUP BY art.name
    ")
    return workers_array2
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
