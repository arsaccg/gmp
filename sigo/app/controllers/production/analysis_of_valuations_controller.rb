class Production::AnalysisOfValuationsController < ApplicationController
  def index
  	@company = params[:company_id]
  	@workingGroups = WorkingGroup.all
    @sector = Sector.where("code LIKE '__'")
    @subsectors = Sector.where("code LIKE '____'")
    CategoryOfWorker.where("name LIKE '%Jefe de Frente%'").each do |front_chief|
      @front_chiefs = front_chief.workers
    end
    CategoryOfWorker.where("name LIKE '%Maestro de Obra%'").each do |master_builder|
      @master_builders = master_builder.workers
    end
    TypeEntity.where("name LIKE '%Proveedores%'").each do |executor|
      @executors = executor.entities
    end
    render layout: false
  end

  def show
  end

  def get_report
    @totalprice = 0
    @cad = Array.new
    @cad2 = Array.new
    @company = params[:company_id]

    if params[:front_chief]=="0" && params[:master_builder] == "0"
      CategoryOfWorker.where("name LIKE '%Jefe de Frente%'").each do |front_chief|
        @front_chief = front_chief.workers
      end
      @front_chief.each do |fc|
        @cad2 << fc.id
      end
      CategoryOfWorker.where("name LIKE '%Maestro de Obra%'").each do |master_builder|
        @master_builders = master_builder.workers
      end
      @master_builders.each do |mb|
        @cad2 << mb.id
      end
    end

    if params[:front_chief]!="0" && params[:master_builder] == "0"
      @cad2 << params[:front_chief]
    end

    if params[:front_chief]=="0" && params[:master_builder] != "0"
      @cad2 << params[:master_builder]
    end

    if params[:front_chief]!="0" && params[:master_builder] != "0"
      @cad2 << params[:front_chief]
      @cad2 << params[:master_builder]
    end

    if params[:executor] != '0'
      @working_group=WorkingGroup.where("executor_id LIKE ?", params[:executor])
    else      
      @working_group = WorkingGroup.all
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
    @cad2 = @cad2.join(',')
    @workers_array = business_days_array(start_date, end_date, @cad, @cad2)
    @workers_array2 = business_days_array2(start_date, end_date, @cad, @cad2)
    @workers_array3 = business_days_array3(start_date, end_date, @cad, @cad2)
    @workers_array.each do |workerDetail|
      @totalprice += workerDetail[7] + workerDetail[8] + workerDetail[9]
    end
    render(partial: 'report_table', :layout => false)
  end

  def business_days_array(start_date, end_date, working_group_id, front_chief_id)
    workers_array = ActiveRecord::Base.connection.execute("
      SELECT  cow.name AS category,
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
      FROM part_people p, unit_of_measurements uom, part_person_details ppd, workers w, category_of_workers cow
      WHERE p.working_group_id IN(" + working_group_id + ")
      AND p.date_of_creation BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND p.id = ppd.part_person_id 
      AND ppd.worker_id = w.id
      AND w.id  IN(" + front_chief_id + ")
      AND w.category_of_worker_id = cow.id
      AND uom.id = cow.unit_of_measurement_id
      GROUP BY cow.name
    ")
    return workers_array
  end

  def business_days_array2(start_date, end_date, working_group_id, front_chief_id)
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

  def business_days_array3(start_date, end_date, working_group_id, front_chief_id)
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

  def frontChief
    if params[:front_chief_id]=="0"
      TypeEntity.where("name LIKE '%Proveedores%'").each do |ex|
        @executor = ex.entities
      end
    else
      executor = WorkingGroup.where("front_chief_id LIKE ?", params[:front_chief_id])
      @executor = Array.new
      Entity.all.each do |ent|
        executor.each do |exe|
          if ent.id==exe.executor_id
            @executor << ent
          end
        end
      end
    end
    render json: {:executor => @executor}
  end

  def executor
    if params[:front_chief_id]=="0" && params[:executor_id]=="0"
      master = WorkingGroup.all
    else
      if params[:front_chief_id]=="0" && params[:executor_id]!="0"
        master = WorkingGroup.where("executor_id LIKE ?", params[:executor_id])
      else
        if params[:front_chief_id]!="0" && params[:executor_id]=="0"
          master = WorkingGroup.where("front_chief_id LIKE ?", params[:front_chief_id])
        else
          master = WorkingGroup.where("front_chief_id LIKE ? AND executor_id LIKE ?", params[:front_chief_id], params[:executor_id])
        end  
      end
    end
    @master = Array.new
    Worker.all.each do |w|
      master.each do |mas|
        if w.id==mas.master_builder_id
          @master << w
        end
      end
    end
    render json: {:master => @master}
  end
end