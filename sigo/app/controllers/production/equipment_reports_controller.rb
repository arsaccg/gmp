class Production::EquipmentReportsController < ApplicationController
  def index
    @company = get_company_cost_center('company')
    @workingGroups = WorkingGroup.all
    @article = Article.where("type_of_article_id = 3")
    render layout: false
  end

  def complete
    @combo=Array.new
    i=0

    if params[:chosen] == "0"
    elsif params[:chosen] == "specific"
      articles = ActiveRecord::Base.connection.execute("SELECT sed.code, CONCAT( sed.code,  ' ', a.name ) AS name FROM  `subcontract_equipment_details` sed,  `articles` a,  `part_of_equipments` pe WHERE sed.article_id = a.id AND pe.equipment_id = a.id GROUP BY pe.equipment_id")
      articles.each do |part|
        @combo << { 'id' => part[0], 'name' => part[1]}
      end
    elsif params[:chosen] == "operador"
      pw_id = Array.new
      if params[:chosen] == "operador"
        PositionWorker.where("name LIKE '%operador%'").each do |pw|
          pw_id = pw.id
        end
      end
      Worker.where("position_worker_id LIKE ?", pw_id).each do |w|
        @combo << { 'id' => w.id.to_i, 'name' => w.first_name + ' '+ w.paternal_surname+' '+w.maternal_surname }
        i+=1
      end
    elsif params[:chosen] == 'frente'
      Sector.where("code LIKE '____'").each do |art|
        @combo << art
      end
    elsif params[:chosen] == "equipment"
      SubcontractEquipmentDetail.all.each do |sed|
        Article.where("code LIKE '03________' AND code NOT LIKE '0332______'").each do |art|
          if sed.article_id == art.id
            @combo << art
          end
        end
      end
    end
    render json: {:combo => @combo}  
  end

  def get_report
    @article= params[:article]
    start_date = params[:start_date]
    end_date = params[:end_date]
    @select1 = params[:select1]
    if @select1 == 'specific'
      @poe_array = poe_arrayworker(start_date, end_date, @article)
  		@poe_array2 = poe_array2(start_date, end_date, @article)
      @subcontract = SubcontractEquipmentDetail.find_by_code(params[:article])
    elsif @select1 == 'operador'
      @poe_array = poe_arrayequipment(start_date, end_date, @article)
      @poe_array2 = poe_array3(start_date, end_date, @article)
      @worker = Worker.find_by_id(params[:article])
    elsif @select1 == 'frente'
      @poe_array = poe_arraysector(start_date, end_date, @article)
      @poe_array2 = poe_array4(start_date, end_date, @article)
      @sector = Sector.find_by_id(params[:article])
    elsif @select1 == 'equipment'
      @poe_array = poe_arrayarticle(start_date, end_date, @article)
      @poe_array2 = poe_array5(start_date, end_date, @article)
      @article = Article.find_by_id(params[:article])
    end
		render(partial: 'report_table', :layout => false)
	end

  def poe_arrayworker(start_date, end_date, working_group_id)
    @result = Array.new
    workers = PartOfEquipment.get_workers(working_group_id, start_date, end_date)
    workers.each do |w|
      array = Array.new
      index = 1
      @totaleffehours = 0
      @totalfuel = 0
      @totalratio = 0
      PartOfEquipment.get_report_per_worker(working_group_id, start_date, end_date, w[0]).each do |rpw|
        array << [index, rpw[1], rpw[2], rpw[3], rpw[4]]
        @totaleffehours += rpw[2].to_f
        @totalfuel += rpw[3].to_f
        index += 1
      end
      @ratio = @totalfuel / @totaleffehours
      @ratio = @ratio.round(2)
      @result << [w[1] => ['data' => array, 'hours' => @totaleffehours, 'fuel' => @totalfuel, 'ratio' => @ratio]]
    end
    return @result
  end

  def poe_arrayequipment(start_date, end_date, working_group_id)
    @result = Array.new
    equipments = PartOfEquipment.get_equipments(working_group_id, start_date, end_date)
    equipments.each do |w|
      array = Array.new
      index = 1
      @totaleffehours = 0
      @totalfuel = 0
      @totalratio = 0
      PartOfEquipment.get_report_per_equipments(working_group_id, start_date, end_date, w[0]).each do |rpw|
        array << [index, rpw[1], rpw[2], rpw[3], rpw[4]]
        @totaleffehours += rpw[2].to_f
        @totalfuel += rpw[3].to_f
        index += 1
      end
      @ratio = @totalfuel / @totaleffehours
      @ratio = @ratio.round(2)
      @result << [w[1] => ['data' => array, 'hours' => @totaleffehours, 'fuel' => @totalfuel, 'ratio' => @ratio]]
    end
    return @result
  end

  def poe_arraysector(start_date, end_date, working_group_id)
    @result = Array.new
    equipments = PartOfEquipment.get_equipments_per_sector(working_group_id, start_date, end_date)
    equipments.each do |w|
      array = Array.new
      index = 1
      @totaleffehours = 0
      @totalfuel = 0
      @totalratio = 0
      PartOfEquipment.get_report_per_equipments_per_sector(working_group_id, start_date, end_date, w[0]).each do |rpw|
        array << [index, rpw[1], rpw[2], rpw[3], rpw[4]]
        @totaleffehours += rpw[2].to_f
        @totalfuel += rpw[3].to_f
        index += 1
      end
      @ratio = @totalfuel / @totaleffehours
      @ratio = @ratio.round(2)
      @result << [w[1] => ['data' => array, 'hours' => @totaleffehours, 'fuel' => @totalfuel, 'ratio' => @ratio]]
    end
    return @result
  end

  def poe_arrayarticle(start_date, end_date, working_group_id)
    @result = Array.new
    equipments = PartOfEquipment.get_equipments_per_article(working_group_id, start_date, end_date)
    equipments.each do |w|
      array = Array.new
      index = 1
      @totaleffehours = 0
      @totalfuel = 0
      @totalratio = 0
      PartOfEquipment.get_report_per_equipments_per_article(working_group_id, start_date, end_date, w[0]).each do |rpw|
        array << [index, rpw[1], rpw[2], rpw[3], rpw[4]]
        @totaleffehours += rpw[2].to_f
        @totalfuel += rpw[3].to_f
        index += 1
      end
      @ratio = @totalfuel / @totaleffehours
      @ratio = @ratio.round(2)
      @result << [w[1] => ['data' => array, 'hours' => @totaleffehours, 'fuel' => @totalfuel, 'ratio' => @ratio]]
    end
    return @result
  end

  def poe_array2(start_date, end_date, working_group_id)
    poe_array2 = ActiveRecord::Base.connection.execute("
      SELECT pha.id, pha.name , SUM(poed.effective_hours), ROUND (SUM(poed.fuel),2), ROUND( ( SUM(poed.fuel) / SUM(poed.effective_hours) ), 2)
			FROM part_of_equipments poe, workers wo, part_of_equipment_details poed,phases pha,subcontract_equipment_details sced 
			WHERE sced.code IN(" + working_group_id + ") 
			AND poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
			AND poe.worker_id=wo.id 
			AND poe.equipment_id=sced.article_id 
			AND poe.id=poed.part_of_equipment_id 
			AND poe.subcontract_equipment_id=sced.subcontract_equipment_id 
			AND poed.phase_id=pha.id
			GROUP BY poed.phase_id
    ")
    return poe_array2
  end

  def poe_array3(start_date, end_date, working_group_id)
    poe_array2 = ActiveRecord::Base.connection.execute("
      SELECT sced.code, art.name, SUM(poed.effective_hours), ROUND (SUM(poed.fuel),2), ROUND( ( SUM(poed.fuel) / SUM(poed.effective_hours) ), 2)
      FROM part_of_equipments poe, part_of_equipment_details poed, subcontract_equipment_details sced, articles art 
      WHERE poe.worker_id IN(" + working_group_id + ") 
      AND poe.date BETWEEN '" + start_date + "' AND '" + end_date + "' 
      AND poe.equipment_id=sced.article_id 
      AND poe.equipment_id=art.id
      AND poe.id=poed.part_of_equipment_id 
      AND poe.subcontract_equipment_id=sced.subcontract_equipment_id 
      GROUP BY sced.code
    ")
    return poe_array2
  end

  def poe_array4(start_date, end_date, working_group_id)
    poe_array2 = ActiveRecord::Base.connection.execute("
      SELECT sced.code, art.name, SUM(poed.effective_hours), ROUND (SUM(poed.fuel),2), ROUND( ( SUM(poed.fuel) / SUM(poed.effective_hours) ), 2)
      FROM part_of_equipments poe, part_of_equipment_details poed, subcontract_equipment_details sced, articles art 
      WHERE poed.sector_id IN(" + working_group_id + ") 
      AND poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND poe.equipment_id=sced.article_id 
      AND poe.equipment_id=art.id
      AND poe.id=poed.part_of_equipment_id 
      AND poe.subcontract_equipment_id=sced.subcontract_equipment_id
      GROUP BY sced.code
    ")
    return poe_array2
  end

  def poe_array5(start_date, end_date, working_group_id)
    poe_array2 = ActiveRecord::Base.connection.execute("
      SELECT sced.code, art.name , SUM(poed.effective_hours), ROUND (SUM(poed.fuel),2), ROUND( ( SUM(poed.fuel) / SUM(poed.effective_hours) ), 2)
      FROM part_of_equipments poe, part_of_equipment_details poed,subcontract_equipment_details sced, articles art 
      WHERE poe.equipment_id IN(" + working_group_id + ") 
      AND poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND poe.equipment_id=sced.article_id 
      AND poe.equipment_id=art.id
      AND poe.id=poed.part_of_equipment_id 
      AND poe.subcontract_equipment_id=sced.subcontract_equipment_id
      GROUP BY sced.code
    ")
    return poe_array2
  end

end