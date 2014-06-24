class Production::EquipmentReportsController < ApplicationController
  def index
    @company = get_company_cost_center('company')
    @workingGroups = WorkingGroup.all
    @article = Article.where("type_of_article_id = 3")
    @week = CostCenter.getWeek(get_company_cost_center('cost_center'),Time.now.to_date.to_s)
    render layout: false
  end

  def complete
    @combo=Array.new
    i=0

    if params[:chosen] == "0"
    elsif params[:chosen] == "specific"
      articles = ActiveRecord::Base.connection.execute("SELECT sed.code, CONCAT( sed.code,  ' ', a.name ) AS name FROM  `subcontract_equipment_details` sed,  `articles` a,  `part_of_equipments` pe WHERE sed.article_id = a.id AND sed.article_id = a.id")
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
        @combo << { 'id' => w.id.to_i, 'name' => w.entity.name + ' '+ w.entity.paternal_surname+' '+w.entity.maternal_surname }
        i+=1
      end
    elsif params[:chosen] == 'frente'
      Sector.where("code LIKE '____'").each do |art|
        @combo << art
      end
    elsif params[:chosen] == "equipment"
      SubcontractEquipmentDetail.all.group('article_id').each do |sed|
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
    @week3 = Array.new
    @cad = Array.new
    @cad2 = Array.new
    @cad3 = Array.new
    @cad4 = Array.new
    @week = CostCenter.getWeek(get_company_cost_center('cost_center'),Time.now.to_date.to_s)
    if @week.count>=10
      @week3 = CostCenter.getWeek3(get_company_cost_center('cost_center'),Time.now.to_date.to_s,10)
      @week3.each do |week3|
        @cad << week3[1] + ' ' + week3[2].strftime("%d/%m") + '-' + week3[3].strftime("%d/%m")
      end
      @cad.reverse!
    else
      @week2 = CostCenter.getWeek2(get_company_cost_center('cost_center'),Time.now.to_date.to_s,10-@week.count)
      @week.each do |week|
        @week3 << week
      end
      @week2.each do |week|
        @week3 << week
      end
      @week3.each do |week3|
        @cad << week3[1] + ' ' + week3[2].strftime("%d/%m") + '-' + week3[3].strftime("%d/%m")
      end
    end
    @result = params[:start_date].split(/,/)
    @article= params[:article]
    start_date = @result[1]
    end_date = @result[2]
    @select1 = params[:select1]
    if @select1 == 'specific'
      @poe_array = poe_arrayworker(start_date, end_date, @article)
  		@poe_array2 = poe_array2(start_date, end_date, @article)
      @subcontract = SubcontractEquipmentDetail.find_by_code(params[:article])
      @poe_array2.each do |pa|
        @theoretical_value = pa[5]
      end
      @week3.each do |week3|
        @cad2 = PartOfEquipment.get_workers(@article, week3[2], week3[3])
        @cad2.each do |cad|
          @cad3 << cad[0]
        end
      end
      @cad3 = @cad3.uniq
      @cad3.each do |cad3|
        @week3.each do |week3|
          @totaleffehours = 0
          @totalfuel = 0
          @ratio = 0
          PartOfEquipment.get_report_per_worker(@article, week3[2], week3[3], cad3).each do |rpw|
            @totaleffehours += rpw[2].to_f
            @totalfuel += rpw[3].to_f
          end
          if @totaleffehours==0
            @totaleffehours=1
          end
          @ratio = @totalfuel / @totaleffehours
          @ratio = @ratio.round(2)
          @cad4 << @ratio
        end
      end
    elsif @select1 == 'operador'
      @poe_array = poe_arrayequipment(start_date, end_date, @article)
      @poe_array2 = poe_array3(start_date, end_date, @article)
      @worker = Worker.find_by_id(params[:article])
      @theoretical_value = 1
      @week3.each do |week3|
        @cad2 = PartOfEquipment.get_equipments(@article, week3[2], week3[3])
        @cad2.each do |cad|
          @cad3 << cad[0]
        end
      end
      @cad3 = @cad3.uniq
      @cad3.each do |cad3|
        @week3.each do |week3|
          @totaleffehours = 0
          @totalfuel = 0
          @ratio = 0
          PartOfEquipment.get_report_per_equipments(@article, week3[2], week3[3], cad3).each do |rpw|
            @totaleffehours += rpw[2].to_f
            @totalfuel += rpw[3].to_f
          end
          if @totaleffehours==0
            @totaleffehours=1
          end
          @ratio = @totalfuel / @totaleffehours
          @ratio = @ratio.round(2)
          @cad4 << @ratio
        end
      end
    elsif @select1 == 'frente'
      @poe_array = poe_arraysector(start_date, end_date, @article)
      @poe_array2 = poe_array4(start_date, end_date, @article)
      @sector = Sector.find_by_id(params[:article])
      @theoretical_value = 1
      @week3.each do |week3|
        @cad2 = PartOfEquipment.get_equipments_per_sector(@article, week3[2], week3[3])
        @cad2.each do |cad|
          @cad3 << cad[0]
        end
      end
      @cad3 = @cad3.uniq
      @cad3.each do |cad3|
        @week3.each do |week3|
          @totaleffehours = 0
          @totalfuel = 0
          @ratio = 0
          PartOfEquipment.get_report_per_equipments_per_sector(@article, week3[2], week3[3], cad3).each do |rpw|
            @totaleffehours += rpw[2].to_f
            @totalfuel += rpw[3].to_f
          end
          if @totaleffehours==0
            @totaleffehours=1
          end
          @ratio = @totalfuel / @totaleffehours
          @ratio = @ratio.round(2)
          @cad4 << @ratio
        end
      end
    elsif @select1 == 'equipment'
      @poe_array = poe_arrayarticle(start_date, end_date, @article)
      @poe_array2 = poe_array5(start_date, end_date, @article)
      @article2 = Article.find_by_id(params[:article])
      @poe_array2.each do |pa|
        @theoretical_value = pa[5]
      end
      @week3.each do |week3|
        @cad2 = PartOfEquipment.get_equipments_per_article(@article, week3[2], week3[3])
        @cad2.each do |cad|
          @cad3 << cad[0]
        end
      end
      @cad3 = @cad3.uniq
      @cad3.each do |cad3|
        @week3.each do |week3|
          @totaleffehours = 0
          @totalfuel = 0
          @ratio = 0
          PartOfEquipment.get_report_per_equipments_per_article(@article, week3[2], week3[3], cad3).each do |rpw|
            @totaleffehours += rpw[2].to_f
            @totalfuel += rpw[3].to_f
          end
          if @totaleffehours==0
            @totaleffehours=1
          end
          @ratio = @totalfuel / @totaleffehours
          @ratio = @ratio.round(2)
          @cad4 << @ratio
        end
      end
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
        array << [index, rpw[1], rpw[2], rpw[3], rpw[4], rpw[5]]
        @totaleffehours += rpw[2].to_f
        @totalfuel += rpw[3].to_f
        index += 1
      end
      if @totaleffehours==0
        @totaleffehours=1
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
        array << [index, rpw[1], rpw[2], rpw[3], rpw[4], rpw[5]]
        @totaleffehours += rpw[2].to_f
        @totalfuel += rpw[3].to_f
        index += 1
      end
      if @totaleffehours==0
        @totaleffehours=1
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
      if @totaleffehours==0
        @totaleffehours=1
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
        array << [index, rpw[1], rpw[2], rpw[3], rpw[4], rpw[5]]
        @totaleffehours += rpw[2].to_f
        @totalfuel += rpw[3].to_f
        index += 1
      end
      if @totaleffehours==0
        @totaleffehours=1
      end
      @ratio = @totalfuel / @totaleffehours
      @ratio = @ratio.round(2)
      @result << [w[1] => ['data' => array, 'hours' => @totaleffehours, 'fuel' => @totalfuel, 'ratio' => @ratio]]
    end
    return @result
  end

  def poe_array2(start_date, end_date, working_group_id)
    poe_array2 = ActiveRecord::Base.connection.execute("
      SELECT pha.id, pha.name , SUM(poed.effective_hours), ROUND (SUM(poed.fuel),2), ROUND( ( SUM(poed.fuel) / SUM(poed.effective_hours) ), 2), tv.theoretical_value 
			FROM part_of_equipments poe, workers wo, part_of_equipment_details poed,phases pha,subcontract_equipment_details sced , theoretical_values tv 
			WHERE sced.code LIKE '" + working_group_id + "' 
			AND poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
			AND poe.worker_id=wo.id 
			AND poe.equipment_id=sced.id 
      AND sced.article_id=tv.article_id
			AND poe.id=poed.part_of_equipment_id 
			AND poe.subcontract_equipment_id=sced.subcontract_equipment_id 
			AND poed.phase_id=pha.id
			GROUP BY poed.phase_id
    ")
    return poe_array2
  end

  def poe_array3(start_date, end_date, working_group_id)
    poe_array2 = ActiveRecord::Base.connection.execute("
      SELECT sced.code, art.name, SUM(poed.effective_hours), ROUND (SUM(poed.fuel),2), ROUND( ( SUM(poed.fuel) / SUM(poed.effective_hours) ), 2), tv.theoretical_value 
      FROM part_of_equipments poe, part_of_equipment_details poed, subcontract_equipment_details sced, articles art , theoretical_values tv 
      WHERE poe.worker_id IN(" + working_group_id + ") 
      AND poe.date BETWEEN '" + start_date + "' AND '" + end_date + "' 
      AND poe.equipment_id=sced.id 
      AND sced.article_id=art.id
      AND sced.article_id=tv.article_id
      AND poe.id=poed.part_of_equipment_id 
      AND poe.subcontract_equipment_id=sced.subcontract_equipment_id 
      GROUP BY sced.code
    ")
    return poe_array2
  end

  def poe_array4(start_date, end_date, working_group_id)
    poe_array2 = ActiveRecord::Base.connection.execute("
      SELECT sced.code, art.name, SUM(poed.effective_hours), ROUND (SUM(poed.fuel),2), ROUND( ( SUM(poed.fuel) / SUM(poed.effective_hours) ), 2), tv.theoretical_value 
      FROM part_of_equipments poe, part_of_equipment_details poed, subcontract_equipment_details sced, articles art , theoretical_values tv 
      WHERE poed.sector_id IN(" + working_group_id + ") 
      AND poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND poe.equipment_id=sced.id 
      AND sced.article_id=art.id
      AND sced.article_id=tv.article_id
      AND poe.id=poed.part_of_equipment_id 
      AND poe.subcontract_equipment_id=sced.subcontract_equipment_id
      GROUP BY sced.code
    ")
    return poe_array2
  end
 
  def poe_array5(start_date, end_date, working_group_id)
    poe_array2 = ActiveRecord::Base.connection.execute("
      SELECT sced.code, art.name , SUM(poed.effective_hours), ROUND (SUM(poed.fuel),2), ROUND( ( SUM(poed.fuel) / SUM(poed.effective_hours) ), 2), tv.theoretical_value 
      FROM part_of_equipments poe, part_of_equipment_details poed,subcontract_equipment_details sced, articles art , theoretical_values tv 
      WHERE sced.article_id IN(" + working_group_id + ") 
      AND poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND poe.equipment_id=sced.id 
      AND sced.article_id=art.id
      AND sced.article_id=tv.article_id
      AND poe.id=poed.part_of_equipment_id 
      AND poe.subcontract_equipment_id=sced.subcontract_equipment_id
      GROUP BY sced.code
    ")
    return poe_array2
  end
end