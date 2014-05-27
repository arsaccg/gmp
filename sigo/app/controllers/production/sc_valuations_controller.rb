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
    @cad = Array.new
    @cad2 = Array.new
    @company = params[:company_id]
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
