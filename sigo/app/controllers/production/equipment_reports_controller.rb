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
    elsif params[:chosen] == "operador" ||  params[:chosen] == "frente"
      pw_id = Array.new
      if params[:chosen] == "operador"
        PositionWorker.where("name LIKE '%operador%'").each do |pw|
          pw_id = pw.id
        end
      else
        PositionWorker.where("name LIKE '%frente%'").each do |pw|
          pw_id = pw.id
        end
      end
      Worker.where("position_worker_id LIKE ?", pw_id).each do |w|
        @combo << { 'id' => w.id.to_i, 'name' => w.first_name + ' '+ w.paternal_surname+' '+w.maternal_surname }
        i+=1
      end
    elsif params[:chosen] == "equipment"
      Article.where("code LIKE '03________' AND code NOT LIKE '0332______'").each do |art|
        @combo << art
      end
    end
    render json: {:combo => @combo}  
  end

  def get_report
    @article= params[:article]
    start_date = params[:start_date]
    end_date = params[:end_date]
    @poe_array = poe_array(start_date, end_date, @article)
		@poe_array2 = poe_array2(start_date, end_date, @article)
		render(partial: 'report_table', :layout => false)
	end

  def poe_array(start_date, end_date, working_group_id)
    @result = Array.new

    workers = PartOfEquipment.get_workers(working_group_id, start_date, end_date)
    workers.each do |w|
      array = Array.new
      @totaleffehours = 0
      @totalfuel = 0
      @totalratio = 0
      PartOfEquipment.get_report_per_worker(working_group_id, start_date, end_date, w[0]).each do |rpw|
        array << [rpw[0], rpw[1], rpw[2], rpw[3], rpw[4]]
        @totaleffehours += rpw[2].to_f
        @totalfuel += rpw[3].to_f
      end
      @ratio = @totalfuel / @totaleffehours
      @result << [w[1] => ['data' => array, 'hours' => @totaleffehours, 'fuel' => @totalfuel, 'ratio' => @ratio]]
    end

    return @result
  end

  def poe_array2(start_date, end_date, working_group_id)
    poe_array2 = ActiveRecord::Base.connection.execute("
      SELECT pha.id, pha.name , SUM(poed.effective_hours) , SUM(poe.fuel_amount), ROUND((SUM(poe.fuel_amount)/SUM(poed.effective_hours)), 2) 
			FROM part_of_equipments poe, workers wo, part_of_equipment_details poed,phases pha,subcontract_equipment_details sced 
			WHERE sced.code IN(123) 
			AND poe.date BETWEEN '2014-05-01' AND '2014-05-10'
			AND poe.worker_id=wo.id 
			AND poe.equipment_id=sced.article_id 
			AND poe.id=poed.part_of_equipment_id 
			AND poe.subcontract_equipment_id=sced.subcontract_equipment_id 
			AND poed.phase_id=pha.id
			GROUP BY poed.phase_id
    ")
    return poe_array2
  end

end
#SELECT wo.first_name, pha.name , poed.effective_hours , poe.fuel_amount, ROUND((poe.fuel_amount/poed.effective_hours), 2)
#FROM part_of_equipments poe, workers wo, part_of_equipment_details poed,phases pha,subcontract_equipment_details sced 
#WHERE sced.code=123 
#AND poe.date BETWEEN '2014-05-01' AND '2014-05-10' 
#AND poe.worker_id=wo.id 
#AND poe.equipment_id=sced.article_id 
#AND poe.id=poed.part_of_equipment_id
#AND poe.subcontract_equipment_id=sced.subcontract_equipment_id 
#AND poed.phase_id=pha.id
