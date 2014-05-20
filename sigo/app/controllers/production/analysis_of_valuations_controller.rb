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
  end
end
