class Production::AnalysisOfValuationsController < ApplicationController
  def index
  	@company = get_company_cost_center('company')
  	@workingGroups = WorkingGroup.all
    @sector = Sector.where("code LIKE '__'")
    @subsectors = Sector.where("code LIKE '____'").first
    @front_chiefs = PositionWorker.find(1).workers # Jefes de Frentes
    @master_builders = PositionWorker.find(2).workers # Capatazes o Maestros de Obra
    @executors = Subcontract.where('entity_id <> 0') # Exclude the Subcontract Default
    render layout: false
  end

  def show
  end

  def get_report
    # Total Prices
    @totalprice = 0 # Personal
    @totalprice2 = 0 # Partidas
    @totalprice3 = 0 # Equipos
    @totalprice_subcontract_real = 0 # Subcontratos
    @total_stock_input_real = 0 # Materiales
    
    # Total Prices Meta
    @m_price_part_person = 0
    @m_price_part_work = 0
    @m_price_part_equipment = 0
    @m_price_part_subcontract = 0
    @total_stock_input_meta = 0

    @cad = Array.new
    @cad2 = Array.new
    @company = params[:company_id]
    @cost_center = get_company_cost_center('cost_center')

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

    # PARTIDAS
    @meta_part_work = Array.new
    budgetanditems_list = Array.new
    @workers_array2 = business_days_array2(start_date, end_date, @cad, @cad2)

    @workers_array2.each do |workerDetail|
      # Get quantity of itembybudgetanditems
      # quantity_ibb = sum_quantity_per_itembybudget_detail(workerDetail[2], workerDetail[5])*workerDetail[3]
      
      # Calculate total of current itembybudget
      total_current_ibb = workerDetail[3]*workerDetail[4] # Cantidad * Precio
      
      # Calculate Total of all itembybudgets
      @totalprice2 += total_current_ibb
      
      # Make a custom Array
      @meta_part_work << [ workerDetail[2], workerDetail[1], workerDetail[3], workerDetail[4], total_current_ibb ]
      
      # List BudgetAndItems
      # [0] => itembybudget_order, [1] => budget_id, [2] => metrado_from_partes
      budgetanditems_list << [ workerDetail[2], workerDetail[5], workerDetail[3] ]
    end

    
    if budgetanditems_list.count > 0
      # Mano de Obra
      @meta_personal = Array.new
      arr_person = Array.new
      @workers_array = business_days_array(start_date, end_date, @cad, @cad2)

      @workers_array.each do |workerDetail|
        if !workerDetail[7].nil? || workerDetail[7] != 0
          @totalprice += workerDetail[7] + workerDetail[8] + workerDetail[9]
        end
      end

      # TODO META Personal
      meta_info = Budget.budget_meta_info_per_person(budgetanditems_list.map(&:first).collect {|x| "'#{x}'"}.join(", "), @cost_center)
      meta_info.each do |minfo|
        value_quantity_from_partes = 0
        pos_arr = budgetanditems_list.transpose.first.index(minfo[0])
        (1..budgetanditems_list[pos_arr].size-1).each { |i|
          value_quantity_from_partes = budgetanditems_list[pos_arr][i+1]
          break
        };
        # MAKE ARRAY META
        arr_person << [ minfo[1].to_s, (minfo[2].to_f*value_quantity_from_partes.to_f), minfo[3].to_f ]
        # TOTAL META
        @m_price_part_person += (minfo[2].to_f*value_quantity_from_partes.to_f)*minfo[3].to_f
      end

      # ORDER ARRAY META
      @meta_personal = arr_person.group_by { |a,_,c| [a,c] }.map { |(a,b),arr_person| [a,arr_person.reduce(0) { |t,(_,e,_)| t + e },b] }


      # Parte de Equipo
      @meta_part_equipment = Array.new
      arr_equipment = Array.new
      @workers_array3 = business_days_array3(start_date, end_date, @cad, @cad2)

      @workers_array3.each do |workerDetail|
        @totalprice3 += workerDetail[4]
      end


      # TODO META equipos
      all_meta_equipments = Budget.budget_meta_info_per_equipment(budgetanditems_list.map(&:first).collect {|x| "'#{x}'"}.join(", "), @cost_center)
      all_meta_equipments.each do |meta_equip|
        value_quantity_from_partes = 0
        pos_arr = budgetanditems_list.transpose.first.index(meta_equip[0])
        (1..budgetanditems_list[pos_arr].size-1).each { |i|
          value_quantity_from_partes = budgetanditems_list[pos_arr][i+1]
          break
        };
        # MAKE ARRAY META
        arr_equipment << [ meta_equip[1], meta_equip[2]*value_quantity_from_partes, meta_equip[3] ]
        # TOTAL META
        @m_price_part_equipment += (meta_equip[2]*value_quantity_from_partes)*meta_equip[3]
      end

      # ORDER ARRAY META
      @meta_part_equipment = arr_equipment.group_by { |a,_,c| [a,c] }.map { |(a,b),arr_equipment| [a,arr_equipment.reduce(0) { |t,(_,e,_)| t + e },b] }


      # TODO META subcontratos
      @meta_part_subcontract = Array.new
      arr_part_subcontract = Array.new
      all_meta_subcontracts = Budget.budget_meta_info_per_subcontract(budgetanditems_list.map(&:first).collect {|x| "'#{x}'"}.join(", "), @cost_center)
      all_meta_subcontracts.each do |meta_subcon|
        value_quantity_from_partes = 0
        pos_arr = budgetanditems_list.transpose.first.index(meta_subcon[0])
        (1..budgetanditems_list[pos_arr].size-1).each { |i|
          value_quantity_from_partes = budgetanditems_list[pos_arr][i+1]
          break
        };
        # MAKE ARRAY META
        arr_part_subcontract << [ meta_subcon[1], meta_subcon[2]*value_quantity_from_partes, meta_subcon[3] ]
        # TOTAL META
        @m_price_part_subcontract += (meta_subcon[2]*value_quantity_from_partes)*meta_subcon[3]
      end

      # ORDER ARRAY META
      @meta_part_subcontract = arr_part_subcontract.group_by { |a,_,c| [a,c] }.map { |(a,b),arr_part_subcontract| [a,arr_part_subcontract.reduce(0) { |t,(_,e,_)| t + e },b] }


      # Consumo de Materiales
      @meta_stock_inputs = Array.new
      arr_stock_input = Array.new
      @stock_inputs = business_days_array4(start_date, end_date, @cad, @cad2)

      # TODO META Materiales
      all_meta_materials = Budget.budget_meta_info_per_material(budgetanditems_list.map(&:first).collect {|x| "'#{x}'"}.join(", "), @cost_center)
      all_meta_materials.each do |meta_material|
        value_quantity_from_partes = 0
        pos_arr = budgetanditems_list.transpose.first.index(meta_material[0])
        (1..budgetanditems_list[pos_arr].size-1).each { |i|
          value_quantity_from_partes = budgetanditems_list[pos_arr][i+1]
          break
        };

        # MAKE Array META
        arr_stock_input << [meta_material[4], meta_material[1], meta_material[2]*value_quantity_from_partes, meta_material[3] ]
        # TOTAL META
        @total_stock_input_meta += (meta_material[2]*value_quantity_from_partes)*meta_material[3]
      end

      # ORDER ARRAY META
      @meta_stock_inputs = arr_stock_input.group_by { |a,b,_,d| [a,b,d] }.map { |(a,b,c),arr_stock_input| [a,b,arr_stock_input.reduce(0) { |t,(_,_,e,_)| t + e },c] }

      # Totalizing Real Prices
      @total_price_real = @totalprice + @totalprice3 + @totalprice_subcontract_real + @total_stock_input_real
      # Totalizing Meta Prices
      @total_price_meta = @m_price_part_person + @m_price_part_equipment + @m_price_part_subcontract + @total_stock_input_meta
    else
      @message_warning = "No hay partidas registradas en ese Rango de Fecha o en ese Sector."
    end

    render(partial: 'report_table', :layout => false)
  end

  # BEGIN Methods for Report Table.

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
        p.date_of_creation, 
        art.id
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
    workers_array2 = ActiveRecord::Base.connection.execute(
      "SELECT
        pwd.itembybudget_id, 
        ibb.subbudgetdetail, 
        ibb.order, 
        SUM(pwd.bill_of_quantitties) as bill_of_quantitties,
        ibb.price as price,
        ibb.budget_id as budget_id,
        p.date_of_creation 
      FROM part_works p, part_work_details pwd, itembybudgets ibb
      WHERE p.date_of_creation BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND p.sector_id IN (" + sector_id.to_s + ")
      AND p.working_group_id IN (" + working_group_id + ")
      AND p.id = pwd.part_work_id
      AND pwd.itembybudget_id =  ibb.id
      GROUP BY ibb.subbudgetdetail"
    )

    return workers_array2
  end

  def sum_quantity_per_itembybudget_detail(order_ibb, budget_id)
    sum_quantity = ActiveRecord::Base.connection.execute(
      "SELECT SUM( quantity ) 
       FROM  `inputbybudgetanditems` 
       WHERE inputbybudgetanditems.order LIKE '" + order_ibb.to_s + "'
       AND budget_id = " + budget_id.to_s
    ).first[0]

    return sum_quantity
  end

  def business_days_array3(start_date, end_date, working_group_id,sector_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT  art.name, 
      uom.name, 
      SUM( poed.effective_hours ), 
      si.price_no_igv, 
      si.price_no_igv*SUM( poed.effective_hours), 
      art.id
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
      SELECT a.id, a.name, 
      u.symbol, 
      SUM(sid.amount),
      a.code 
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

  # END Methods for report Table.

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