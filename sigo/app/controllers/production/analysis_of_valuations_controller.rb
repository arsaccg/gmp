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