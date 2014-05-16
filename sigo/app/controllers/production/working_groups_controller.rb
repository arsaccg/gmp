class Production::WorkingGroupsController < ApplicationController
  def index
    @company = params[:company_id]
    @workingGroups = WorkingGroup.all
    @sector = Sector.where("code LIKE '__'")
    @subsectors = Sector.where("code LIKE '____'")
    TypeEntity.where("name LIKE '%Proveedores%'").each do |entity|
      @entity = entity.entities.first
    end
    CategoryOfWorker.where("name LIKE '%Jefe de Frente%'").each do |front_chief|
      @front_chief = front_chief.workers.first
    end
    CategoryOfWorker.where("name LIKE '%Maestro de Obra%'").each do |master_builder|
      @master_builder = master_builder.workers.first
    end
    render layout: false
  end

  def show
    @workingGroup = WorkingGroup.find(params[:id])
    render layout: false
  end

  def new
    @workingGroup = WorkingGroup.new
    CategoryOfWorker.where("name LIKE '%Jefe de Frente%'").each do |front_chief|
      @front_chiefs = front_chief.workers
    end

    CategoryOfWorker.where("name LIKE '%Maestro de Obra%'").each do |master_builder|
      @master_builders = master_builder.workers
    end
    TypeEntity.where("name LIKE '%Proveedores%'").each do |executor|
      @executors = executor.entities
    end
    @sectors = Sector.where("code LIKE '__'")
    @company = params[:company_id]
    render layout: false
  end

  def create
    workingGroup = WorkingGroup.new(working_groups_parameters)
    if workingGroup.save
      flash[:notice] = "Se ha creado correctamente el trabajador."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      workingGroup.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def edit
    @workingGroup = WorkingGroup.find(params[:id])
    CategoryOfWorker.where("name LIKE '%Jefe de Frente%'").each do |front_chief|
      @front_chiefs = front_chief.workers
    end

    CategoryOfWorker.where("name LIKE '%Maestro de Obra%'").each do |master_builder|
      @master_builders = master_builder.workers
    end
    TypeEntity.where("name LIKE '%Proveedores%'").each do |executor|
      @executors = executor.entities
    end
    @sectors = Sector.where("code LIKE '__'")
    @company = params[:company_id]
    render layout: false
  end

  def update
    workingGroup = WorkingGroup.find(params[:id])
    if workingGroup.update_attributes(working_groups_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      workingGroup.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @workingGroup = workingGroup
      render :edit, layout: false
    end
  end

  def destroy
    workingGroup = WorkingGroup.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el Grupo de Trabajo."
    render :json => workingGroup
  end

  def working_groups_parameters
    params.require(:working_group).permit(:sector_id, :master_builder_id, :front_chief_id, :active, :executor_id)
  end
end
