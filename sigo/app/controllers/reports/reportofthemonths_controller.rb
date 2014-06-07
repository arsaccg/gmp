class Reports::ReportofthemonthsController < ApplicationController

  def index
  	@company = get_company_cost_center('company')
  	@d = Date.today-1.month
  	@dia = @d.at_beginning_of_month.strftime
  	@dia2 = @d.at_end_of_month.strftime
    @cost_center = get_company_cost_center('cost_center')

		@part_work = part_work(@dia, @dia2, @cost_center)
		@part_work.each do |workerDetail|
      @partwork = workerDetail[0]
    end
    @part_work2 = part_work2(@dia, @dia2, @cost_center)
		@part_work2.each do |workerDetail|
      @partwork2 = workerDetail[0]
    end

		@part_equipment = part_equipment(@dia, @dia2, @cost_center)
		@part_equipment.each do |workerDetail|
      @partequipment = workerDetail[0]
    end
    @part_equipment2 = part_equipment2(@dia, @dia2, @cost_center)
		@part_equipment2.each do |workerDetail|
      @partequipment2 = workerDetail[0]
    end

		@part_people = part_people(@dia, @dia2, @cost_center)
		@part_people.each do |workerDetail|
      @partpeople = workerDetail[0]
    end
    @part_people2 = part_people2(@dia, @dia2, @cost_center)
		@part_people2.each do |workerDetail|
      @partpeople2 = workerDetail[0]
    end

		@order_of_service = order_of_service(@dia, @dia2, @cost_center)
		@order_of_service.each do |workerDetail|
      @orderofservice = workerDetail[0]
    end
    @order_of_service2 = order_of_service2(@dia, @dia2, @cost_center)
		@order_of_service2.each do |workerDetail|
      @orderofservice2 = workerDetail[0]
    end

		@sc_valuations = sc_valuations(@dia, @dia2, @cost_center)
		@sc_valuations.each do |workerDetail|
      @scvaluations = workerDetail[0]
    end
    @sc_valuations2 = sc_valuations2(@dia, @dia2, @cost_center)
		@sc_valuations2.each do |workerDetail|
      @scvaluations2 = workerDetail[0]
    end

    if @partwork.nil?
      @partwork=0
    end
    if @partwork2.nil?
      @partwork2=0
    end
    if @partequipment.nil?
      @partequipment=0
    end
    if @partequipment2.nil?
      @partequipment2=0
    end
    if @partpeople.nil?
      @partpeople=0
    end
    if @partpeople2.nil?
      @partpeople2=0
    end
    if @orderofservice.nil?
      @orderofservice=0
    end
    if @orderofservice2.nil?
      @orderofservice2=0
    end
    if @scvaluations.nil?
      @scvaluations=0
    end

    if @scvaluations2.nil?
      @scvaluations2=0
    end
    
		render layout: false
  end

  def part_work(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT SUM(pwd.bill_of_quantitties*si.price) AS PartWork 
			FROM part_works pw, part_work_details pwd, articles art,subcontract_inputs si 
			WHERE pw.date_of_creation BETWEEN '" + start_date + "' AND '" + end_date + "'
			AND pw.id = pwd.part_work_id
			AND pwd.article_id = art.id
			AND si.article_id = pwd.article_id
      AND pw.cost_center_id IN(" + working_group_id + ")
    ")
    return workers_array3
  end

  def part_work2(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT SUM(pwd.bill_of_quantitties*si.price) AS PartWork 
			FROM part_works pw, part_work_details pwd, articles art,subcontract_inputs si 
			WHERE pw.date_of_creation < '" + end_date + "'
			AND pw.id = pwd.part_work_id
			AND pwd.article_id = art.id
			AND si.article_id = pwd.article_id
      AND pw.cost_center_id IN(" + working_group_id + ")
    ")
    return workers_array3
  end

  def part_equipment(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT SUM(poed.effective_hours*si.price) AS PartEquip
			FROM part_of_equipments poe, part_of_equipment_details poed, articles art,subcontract_inputs si 
			WHERE poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
			AND poe.id = poed.part_of_equipment_id
			AND poe.equipment_id = art.id
			AND si.article_id = poe.equipment_id
      AND poe.cost_center_id IN(" + working_group_id + ")
      AND poed.phase_id < 8999
    ")
    return workers_array3
  end

  def part_equipment2(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT SUM(poed.effective_hours*si.price) AS PartEquip
			FROM part_of_equipments poe, part_of_equipment_details poed, articles art,subcontract_inputs si 
			WHERE poe.date < '" + end_date + "'
			AND poe.id = poed.part_of_equipment_id
			AND poe.equipment_id = art.id
			AND si.article_id = poe.equipment_id
      AND poe.cost_center_id IN(" + working_group_id + ")
      AND poed.phase_id < 8999
    ")
    return workers_array3
  end

  def part_people(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT SUM((ppd.normal_hours*cow.normal_price)+(ppd.he_60*cow.he_60_price)+(ppd.he_100*cow.he_100_price)) AS PartPerson
			FROM part_people pp, part_person_details ppd, articles art, workers wo, category_of_workers cow
			WHERE pp.date_of_creation BETWEEN '" + start_date + "' AND '" + end_date + "'
			AND pp.id = ppd.part_person_id
			AND ppd.worker_id = wo.id
			AND wo.article_id = art.id
			AND art.id = cow.article_id
      AND pp.cost_center_id IN(" + working_group_id + ")
      AND ppd.phase_id < 8999
    ")
    return workers_array3
  end

  def part_people2(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT SUM((ppd.normal_hours*cow.normal_price)+(ppd.he_60*cow.he_60_price)+(ppd.he_100*cow.he_100_price)) AS PartPerson
			FROM part_people pp, part_person_details ppd, articles art, workers wo, category_of_workers cow
			WHERE pp.date_of_creation < '" + end_date + "'
			AND pp.id = ppd.part_person_id
			AND ppd.worker_id = wo.id
			AND wo.article_id = art.id
			AND art.id = cow.article_id
      AND pp.cost_center_id IN(" + working_group_id + ")
      AND ppd.phase_id < 8999
    ")
    return workers_array3
  end

  def order_of_service(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT SUM(oosd.unit_price_igv)
			FROM order_of_services oos, order_of_service_details oosd
			WHERE oosd.order_of_service_id = oos.id
			AND oos.date_of_service BETWEEN '" + start_date + "' AND '" + end_date + "'
			AND oos.cost_center_id IN(" + working_group_id + ")
      AND oosd.phase_id < 8999
    ")
    return workers_array3
  end

  def order_of_service2(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT SUM(oosd.unit_price_igv)
			FROM order_of_services oos, order_of_service_details oosd
			WHERE oosd.order_of_service_id = oos.id
			AND oos.date_of_service < '" + end_date + "'
			AND oos.cost_center_id IN(" + working_group_id + ")
      AND oosd.phase_id < 8999
    ")
    return workers_array3
  end

  def sc_valuations(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT SUM(net_payment) AS SCVALUATION
			FROM  sc_valuations
			WHERE start_date BETWEEN '" + start_date + "' AND '" + end_date + "'
			AND end_date BETWEEN '" + start_date + "' AND '" + end_date + "'
    ")
    return workers_array3
  end

  def sc_valuations2(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT SUM(net_payment) AS SCVALUATION
			FROM  sc_valuations
			WHERE end_date < '" + end_date + "'
    ")
    return workers_array3
  end

end
