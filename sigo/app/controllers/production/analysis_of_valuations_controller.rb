class Production::AnalysisOfValuationsController < ApplicationController
  def index
  	@company = get_company_cost_center('company')
  	@workingGroups = WorkingGroup.all
    @sector = Sector.where("code LIKE '__'")
    @subsectors = Sector.where("code LIKE '____'")
    @front_chiefs = PositionWorker.find(1).workers # Jefes de Frentes
    @master_builders = PositionWorker.find(2).workers # Capatazes o Maestros de Obra
    @executors = Subcontract.where('entity_id <> 0') # Exclude the Subcontract Default
    render layout: false
  end

  def show
  end

  def get_report
    @totalprice = 0
    @totalprice2 = 0
    @totalprice3 = 0
    @cad = Array.new
    @cad2 = Array.new
    @company = params[:company_id]

    if params[:front_chief]=="0" && params[:executor]=="0" && params[:master_builder] == "0"
      @working_group = WorkingGroup.all
    end
    if params[:front_chief]!="0" && params[:executor]=="0" && params[:master_builder] == "0"
      @working_group = WorkingGroup.where("front_chief_id LIKE ?", params[:front_chief])
    end
    if params[:front_chief]=="0" && params[:executor]!="0" && params[:master_builder] == "0"
      @working_group = WorkingGroup.where("executor_id LIKE ?", params[:executor])
    end
    if params[:front_chief]=="0" && params[:executor]=="0" && params[:master_builder] != "0"
      @working_group = WorkingGroup.where("master_builder_id LIKE ?", params[:master_builder])
    end
    if params[:front_chief]!="0" && params[:executor]!="0" && params[:master_builder] == "0"
      @working_group = WorkingGroup.where("front_chief_id LIKE ? AND executor_id LIKE ?", params[:front_chief], params[:executor])
    end
    if params[:front_chief]!="0" && params[:executor]=="0" && params[:master_builder] != "0"
      @working_group = WorkingGroup.where("front_chief_id LIKE ? AND master_builder_id LIKE ?", params[:front_chief], params[:master_builder])
    end
    if params[:front_chief]=="0" && params[:executor]!="0" && params[:master_builder] != "0"
      @working_group = WorkingGroup.where("executor_id LIKE ? AND master_builder_id LIKE ?", params[:executor], params[:master_builder])
    end
    if params[:front_chief]!="0" && params[:executor]!="0" && params[:master_builder] != "0"
      @working_group = WorkingGroup.where("front_chief_id LIKE ? AND executor_id LIKE ? AND master_builder_id LIKE ?", params[:front_chief], params[:executor], params[:master_builder])
    end
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
    if params[:sector] != "0"
      @cad2 = params[:sector]
    else
      @sector = Sector.all
      @sector.each do |st|
        @cad2 << st.id
      end
      @cad2 = @cad2.join(',')
    end
    @workers_array = business_days_array(start_date, end_date, @cad, @cad2)
    @workers_array2 = business_days_array2(start_date, end_date, @cad, @cad2)
    @workers_array3 = business_days_array3(start_date, end_date, @cad, @cad2)
    @workers_array4 = business_days_array4(start_date, end_date, @cad, @cad2)
    @workers_array.each do |workerDetail|
      if !workerDetail[7].nil?
        @totalprice += workerDetail[7] + workerDetail[8] + workerDetail[9]
      end
    end
    @workers_array2.each do |workerDetail|
      @totalprice2 += workerDetail[5]
    end
    @workers_array3.each do |workerDetail|
      @totalprice3 += workerDetail[4]
    end
    @totalprice4 = @totalprice2-@totalprice-@totalprice3
    render(partial: 'report_table', :layout => false)
  end

  def business_days_array(start_date, end_date, working_group_id,sector_id)
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
      FROM part_people p, unit_of_measurements uom, part_person_details ppd, workers w, category_of_workers cow, articles art, worker_contracts wc
      WHERE p.working_group_id IN(" + working_group_id + ")
      AND p.date_of_creation BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND ppd.sector_id IN(" + sector_id + ")
      AND p.id = ppd.part_person_id
      AND w.id = wc.worker_id 
      AND wc.status = 1 
      AND wc.article_id = art.id
      AND ppd.worker_id = w.id
      AND wc.article_id = cow.article_id
      AND uom.id = art.unit_of_measurement_id
      GROUP BY art.name
    ")
    return workers_array
  end

  def business_days_array2(start_date, end_date, working_group_id,sector_id)
    workers_array2 = ActiveRecord::Base.connection.execute("
      SELECT  pwd.article_id, 
        art.name, 
        uom.name, 
        SUM( pwd.bill_of_quantitties ), 
        si.unit_price, 
        si.unit_price*SUM( pwd.bill_of_quantitties ), 
        p.date_of_creation 
      FROM part_works p, part_work_details pwd, articles art, unit_of_measurements uom, subcontract_details si
      WHERE p.date_of_creation BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND p.sector_id IN(" + sector_id + ")
      AND p.working_group_id IN(" + working_group_id + ")
      AND p.id = pwd.part_work_id
      AND pwd.article_id = art.id
      AND uom.id = art.unit_of_measurement_id
      GROUP BY art.name
    ")
    return workers_array2
  end

  def business_days_array3(start_date, end_date, working_group_id,sector_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT  art.name, 
      uom.name, 
      SUM( poed.effective_hours ), 
      si.price_no_igv, 
      si.price_no_igv*SUM( poed.effective_hours) 
      FROM part_of_equipments poe, part_of_equipment_details poed, articles_from_cost_center_"+get_company_cost_center('cost_center').to_s+" art, unit_of_measurements uom, subcontract_equipment_details si
      WHERE poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND poed.sector_id IN(" + sector_id + ")
      AND poe.id=poed.part_of_equipment_id
      AND si.article_id=art.id
      AND poe.equipment_id=si.id
      AND uom.id = art.unit_of_measurement_id
      AND poed.working_group_id IN(" + working_group_id + ")
      GROUP BY art.name
    ")
    return workers_array3
  end

  def business_days_array4(start_date, end_date, working_group_id,sector_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT  a.id, a.name, 
      u.symbol, 
      SUM(sid.amount) 
      FROM articles a, unit_of_measurements u, type_of_articles toa, categories c, stock_inputs si, stock_input_details sid 
      WHERE si.issue_date BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND sid.sector_id IN(" + sector_id + ")
      AND a.id = sid.article_id 
      AND si.input = 0 
      AND si.id = sid.stock_input_id 
      AND a.unit_of_measurement_id = u.id 
      AND a.category_id = c.id 
      AND toa.id = a.type_of_article_id
      AND si.working_group_id IN(" + working_group_id + ")
      GROUP BY a.code
    ")
    return workers_array3
  end

  def frontChief
    @executor = Array.new
    if params[:front_chief_id]=="0"
      @executor = TypeEntity.find_by_preffix("P").entities
    else
      executor_ids = WorkingGroup.select(:executor_id).distinct.where("front_chief_id LIKE ?", params[:front_chief_id]).map(&:executor_id).join(',')
      @executor = Entity.select(:name).where("id IN (?)", executor_ids)
    end
    render json: {:executor => @executor}
  end

  def executor
    @master = Array.new

    if params[:front_chief_id]=="0" && params[:executor_id]=="0"
      master = WorkingGroup.select(:master_builder_id).map(&:master_builder_id).join(',')
    else
      if params[:front_chief_id]=="0" && params[:executor_id]!="0"
        master = WorkingGroup.select(:master_builder_id).where("executor_id LIKE ?", params[:executor_id]).map(&:master_builder_id).join(',')
      else
        if params[:front_chief_id]!="0" && params[:executor_id]=="0"
          master = WorkingGroup.select(:master_builder_id).where("front_chief_id LIKE ?", params[:front_chief_id]).map(&:master_builder_id).join(',')
        else
          master = WorkingGroup.select(:master_builder_id).where("front_chief_id LIKE ? AND executor_id LIKE ?", params[:front_chief_id], params[:executor_id]).map(&:master_builder_id).join(',')
        end  
      end
    end

    worker_entity_ids = Worker.select(:entity_id).where("id IN (?)", master).map(&:entity_id).join(',')
    @master = Entity.select(:name).select(:paternal_surname).select(:maternal_surname).where('id IN (?)', worker_entity_ids)

    render json: { :master => @master }
  end
end