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
    @totalprice = 0
    @totalprice2 = 0
    @totalprice3 = 0

    # Total Prices Meta
    @m_price_part_person = 0
    @m_price_part_work = 0
    @m_price_part_equipment = 0

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

    # Mano de Obra
    @meta_personal = Array.new
    @workers_array = business_days_array(start_date, end_date, @cad, @cad2)

    @workers_array.each do |workerDetail|
      if !workerDetail[7].nil? || workerDetail[7] != 0
        @totalprice += workerDetail[7] + workerDetail[8] + workerDetail[9]
      end

      article = Article.find(workerDetail[12])
      meta_info = Budget.budget_meta_info_per_article(article.code, @cost_center)
      if !meta_info.nil? && workerDetail[0] != ''
        @meta_personal << [ workerDetail[0].to_s, meta_info[1].round(2), meta_info[2], meta_info[3] ]
        @m_price_part_person += meta_info[3]
      elsif meta_info.nil? && workerDetail[0] != ''
        @meta_personal << [ workerDetail[0].to_s, 0, 0, 0 ]
        @m_price_part_person += 0
      else
        @meta_personal << [ '-', 0, 0, 0 ]
        @m_price_part_person += 0
      end
    end

    # PARTIDAS
    @meta_part_work = Array.new
    budgetanditems_list = Array.new
    @workers_array2 = business_days_array2(start_date, end_date, @cad, @cad2)

    @workers_array2.each do |workerDetail|
      # Get quantity of itembybudgetanditems
      # quantity_ibb = sum_quantity_per_itembybudget_detail(workerDetail[2], workerDetail[5])*workerDetail[3]
      
      # Calculate total of current itembybudget
      total_current_ibb = workerDetail[3]*workerDetail[4]
      
      # Calculate Total of all itembybudgets
      @totalprice2 += total_current_ibb
      
      # Make a custom Array
      @meta_part_work << [ workerDetail[2], workerDetail[1], workerDetail[3], workerDetail[4], total_current_ibb ]
      
      # List BudgetAndItems
      budgetanditems_list << [ workerDetail[2], workerDetail[5] ]
    end

    # Parte de Equipo
    @meta_part_equipment = Array.new
    @workers_array3 = business_days_array3(start_date, end_date, @cad, @cad2)

    @workers_array3.each do |workerDetail|
      @totalprice3 += workerDetail[4]

      specific = Article.find_idarticle_global_by_specific_idarticle(workerDetail[5], @cost_center)
      article = Article.find(specific[1])
      meta_info = Budget.budget_meta_info_per_article(article.code, @cost_center)
      if !meta_info.nil?
        @meta_part_equipment << [ meta_info[1], meta_info[2], meta_info[3], workerDetail[0] ]
        @m_price_part_equipment += meta_info[3]
      else
        @meta_part_equipment << [ 0, 0, 0 ]
        @m_price_part_equipment += 0
      end
    end

    # Consumo de Materiales
    @meta_stock_inputs = Array.new
    @total_stock_input_meta = 0
    @total_stock_input_real = 0
    @stock_inputs = business_days_array4(start_date, end_date, @cad, @cad2)

    if @stock_inputs.count > 0
      @stock_inputs.each do |m_input|
        meta_info = Budget.budget_meta_info_per_article(m_input[4], @cost_center)
        if !meta_info.nil?
          @meta_stock_inputs << [ m_input[1], meta_info[1], meta_info[2], meta_info[3] ]
          @total_stock_input_real += meta_info[3]
        else
          @meta_stock_inputs << [ '-', '-', 0, 0, 0 ]
        end
      end
    else
      budgetanditems_list.each do |ibb|
        # [0] => itembybudget_order, [1] => budget_id
        list_materials = get_tobi_articles_materials_from_itembybudgets(ibb[0], ibb[1])
        list_materials.each do |material|
          if !@meta_stock_inputs.map(&:first).include? material[0]
            @meta_stock_inputs << [ material[0], material[1], material[2], material[3], material[2]*material[3] ]
          else
            pos_arr = @meta_stock_inputs.transpose.first.index(material[0])
            ((1..@meta_stock_inputs[pos_arr].size-1).each { |i|
              @meta_stock_inputs[pos_arr][i+1] += material[2]
              @meta_stock_inputs[pos_arr][i+3] += (material[2]*material[3])
              break
            }; @meta_stock_inputs)
          end
        end
      end
    end

    @meta_stock_inputs.each do |sti|
      @total_stock_input_meta += sti[4]
    end

    @totalprice4 = @totalprice2-@totalprice-@totalprice3
    @m_total_price = @m_price_part_work - @m_price_part_person - @m_price_part_equipment

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

  def get_tobi_articles_materials_from_itembybudgets(ibb_order, budget_id)
    materials_from_itembybudget = ActiveRecord::Base.connection.execute("
      SELECT 
        ibbi.cod_input, 
        ibbi.input, 
        ROUND(SUM(ibbi.quantity),2)*ibb.measured, 
        ibbi.price 
      FROM `itembybudgets` ibb, `inputbybudgetanditems` ibbi 
      WHERE ibb.order LIKE '" + ibb_order.to_s + "' 
      AND ibb.budget_id = " + budget_id.to_s + " 
      AND ibbi.order = ibb.order 
      AND ibbi.cod_input LIKE '02%' 
      GROUP BY ibbi.cod_input"
    )

    return materials_from_itembybudget
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