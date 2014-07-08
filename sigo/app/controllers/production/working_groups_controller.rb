class Production::WorkingGroupsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @company = get_company_cost_center('company')
    cost_center = get_company_cost_center('cost_center')
    @workingGroups = WorkingGroup.where("cost_center_id = ?", cost_center)
    @sector = Sector.where("code LIKE '__'")
    @subsectors = Sector.where("code LIKE '____'")
    TypeEntity.where("name LIKE '%Proveedores%'").each do |entity|
      @entity = entity.entities.first
    end
    PositionWorker.where("name LIKE 'Jefe de Frente'").each do |front_chief|
      @front_chief = front_chief.workers.first
    end
    PositionWorker.where("name LIKE 'Maestro de Obra'").each do |master_builder|
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
    PositionWorker.where("name LIKE 'Jefe de Frente'").each do |front_chief|
      @front_chiefs = front_chief.workers
    end

    PositionWorker.where("name LIKE 'Maestro de Obra'").each do |master_builder|
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
    workingGroup.cost_center_id = get_company_cost_center('cost_center')
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
    PositionWorker.where("name LIKE 'Jefe de Frente'").each do |front_chief|
      @front_chiefs = front_chief.workers
    end

    PositionWorker.where("name LIKE 'Maestro de Obra'").each do |master_builder|
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
    delete = 0
    partwork = PartWork.where('working_group_id = ?',params[:id])
    partwork.each do |del|
      delete +=1
    end
    partpeople = PartPerson.where('working_group_id = ?',params[:id])
    partpeople.each do |del|
      delete +=1
    end
    if delete > 0
      flash[:error] = "No se puede eliminar el Grupo de Trabajo."
      workingGroup = 'true'
    else
      workingGroup = WorkingGroup.destroy(params[:id])
      flash[:notice] = "Se ha eliminado correctamente el Grupo de Trabajo."
    end
    render :json => workingGroup
  end

  def working_groups_parameters
    params.require(:working_group).permit(:master_builder_id, :front_chief_id, :active, :executor_id, :name)
  end
end
