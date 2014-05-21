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
    @company = params[:company_id]
    @working_group = WorkingGroup.all
    start_date = params[:start_date]
    end_date = params[:end_date]
    @cad = Array.new
    @working_group.each do |wg|
      @cad << wg.id
    end
    @cad = @cad.join(',')
    @workers_array = business_days_array(start_date, end_date, @cad)
    @workers_array.each do |workerDetail|
      @totalprice += workerDetail[7] + workerDetail[8] + workerDetail[9]
    end
    render(partial: 'report_table', :layout => false)
  end

  def business_days_array(start_date, end_date, working_group_id)
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
      AND w.category_of_worker_id = cow.id
      AND uom.id = cow.unit_of_measurement_id
      GROUP BY cow.name
    ")
    return workers_array
  end

<<<<<<< HEAD
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
=======
>>>>>>> fd3e46d3b1b1daadaa3c7d429b1e31dbdf715951
end