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

  def get_report
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
    render(partial: 'report_table', :layout => false)
  end

  def business_days_array(start_date, end_date, working_group_id)

    workers_array = ActiveRecord::Base.connection.execute("
      SELECT  CONCAT( w.first_name, w.second_name, w.paternal_surname, w.maternal_surname ) AS name, 
        cow.name AS category,
        SUM( ppd.normal_hours ) AS normal_hours, 
        SUM( ppd.he_60 ) AS he_60, 
        SUM( ppd.he_100 ) AS he_100, 
        SUM( ppd.total_hours ) AS total_hours, 
        p.date_of_creation 
      FROM part_people p, part_person_details ppd, workers w, category_of_workers cow
      WHERE p.working_group_id IN(" + working_group_id + ")
      AND p.date_of_creation BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND p.id = ppd.part_person_id 
      AND ppd.worker_id = w.id
      AND w.category_of_worker_id = cow.id
      GROUP BY ppd.worker_id
    ")

    return workers_array
  end

end