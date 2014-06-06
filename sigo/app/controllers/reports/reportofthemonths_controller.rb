class Reports::ReportofthemonthsController < ApplicationController

  def index
  	@company = get_company_cost_center('company')
  	@partwork=0
  	@partequipment=0
  	@partpeople=0
  	@orderofservice=0
  	@scvaluations=0
  	@d = Date.today-1.month
  	@dia = @d.at_beginning_of_month.strftime
  	@dia2 = @d.at_end_of_month.strftime
    @cost_center = get_company_cost_center('cost_center')
		@part_work = part_work(@dia, @dia2, @cost_center)
		@part_work.each do |workerDetail|
      @partwork = workerDetail[0]
    end
		@part_equipment = part_equipment(@dia, @dia2, @cost_center)
		@part_equipment.each do |workerDetail|
      @partequipment = workerDetail[0]
    end
		@part_people = part_people(@dia, @dia2, @cost_center)
		@part_people.each do |workerDetail|
      @partpeople = workerDetail[0]
    end
		@sc_valuations = sc_valuations(@dia, @dia2, @cost_center)
		@sc_valuations.each do |workerDetail|
      @scvaluations = workerDetail[0]
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
			WHERE pw.date_of_creation BETWEEN '" + start_date + "' AND '" + end_date + "'
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
			WHERE poe.date BETWEEN '2014-01-1' AND '2014-01-31'
			AND poe.id = poed.part_of_equipment_id
			AND poe.equipment_id = art.id
			AND si.article_id = poe.equipment_id
      AND poe.cost_center_id IN(" + working_group_id + ")
    ")
    return workers_array3
  end

  def part_equipment2(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT SUM(pwd.bill_of_quantitties*si.price) AS PartWork 
			FROM part_works pw, part_work_details pwd, articles art,subcontract_inputs si 
			WHERE pw.date_of_creation BETWEEN '" + start_date + "' AND '" + end_date + "'
			AND pw.id = pwd.part_work_id
			AND pwd.article_id = art.id
			AND si.article_id = pwd.article_id
      AND poe.cost_center_id IN(" + working_group_id + ")
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
    ")
    return workers_array3
  end

  def part_people2(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT SUM((ppd.normal_hours*cow.normal_price)+(ppd.he_60*cow.he_60_price)+(ppd.he_100*cow.he_100_price)) AS PartPerson
			FROM part_people pp, part_person_details ppd, articles art, workers wo, category_of_workers cow
			WHERE pp.date_of_creation BETWEEN '" + start_date + "' AND '" + end_date + "'
			AND pp.id = ppd.part_person_id
			AND ppd.worker_id = wo.id
			AND wo.article_id = art.id
			AND art.id = cow.article_id
      AND pp.cost_center_id IN(" + working_group_id + ")
    ")
    return workers_array3
  end

  def order_of_service(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT SUM(oosd.unit_price_igv) AS ORDER
			FROM order_of_services oos, order_of_service_details oosd
			WHERE oosd.order_of_service_id = oos.id
			AND oos.date_of_service BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND oos.cost_center_id IN(" + working_group_id + ")
    ")
    return workers_array3
  end

  def order_of_service2(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT SUM(oosd.unit_price_igv) AS ORDER
			FROM order_of_services oos, order_of_service_details oosd
			WHERE oosd.order_of_service_id = oos.id
			AND oos.date_of_service BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND oos.cost_center_id IN(" + working_group_id + ")
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
			WHERE start_date BETWEEN '" + start_date + "' AND '" + end_date + "'
			AND end_date BETWEEN '" + start_date + "' AND '" + end_date + "'
    ")
    return workers_array3
  end

end
