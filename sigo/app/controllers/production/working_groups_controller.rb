class Production::WorkingGroupsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @company = get_company_cost_center('company')
    cost_center = get_company_cost_center('cost_center')
    @workingGroups = WorkingGroup.where("cost_center_id = ?", cost_center)
    @sector = Sector.where("code LIKE '__'").first
    @subsectors = Sector.where("code LIKE '____'").first
    @entity = TypeEntity.find_by_preffix("P").entities.first
    #PositionWorker.where("name LIKE 'JEFE DE FRENTE'").each do |front_chief|
    #  @front_chief = front_chief.workers.first
    #end
    #PositionWorker.where("name LIKE 'MAESTRO DE OBRA'").each do |master_builder|
    #  @master_builder = master_builder.workers.first
    #end
    render layout: false
  end

  def show
    @workingGroup = WorkingGroup.find(params[:id])
    render layout: false
  end

  def new
    @workingGroup = WorkingGroup.new
    @workers = Array.new
    @executors = Array.new
    @front_chiefs = Array.new
    @master_builders = Array.new
    Worker.where("cost_center_id = ? AND position_wg_id IS NULL AND state LIKE 'active'", get_company_cost_center('cost_center').to_s).each do |wo|
      @workers << wo
    end
    TypeEntity.find_by_preffix("P").entities.each do |executor|
      @executors << executor
    end
    PositionWorker.find_by_name("Jefe de Frente").workers.where("cost_center_id = "+ get_company_cost_center('cost_center').to_s).each do |front_chief|
      @front_chiefs << front_chief
    end
    @front_chiefs = @front_chiefs + @workers
    @front_chiefs = @front_chiefs.uniq
    PositionWorker.find_by_name("Capataz").workers.where("cost_center_id = "+ get_company_cost_center('cost_center').to_s).each do |master_builder|
      @master_builders << master_builder
    end
    @master_builders = @master_builders + @workers
    @master_builders = @master_builders.uniq
    @sectors = Sector.where("code LIKE '__'")
    @company = params[:company_id]
    render layout: false
  end

  def create
    workingGroup = WorkingGroup.new(working_groups_parameters)
    workingGroup.cost_center_id = get_company_cost_center('cost_center')
    if workingGroup.save
      ActiveRecord::Base.connection.execute("
          UPDATE workers SET
          position_wg_id = 1
          WHERE id = "+workingGroup.front_chief_id.to_s+"
        ")
      ActiveRecord::Base.connection.execute("
          UPDATE workers SET
          position_wg_id = 2
          WHERE id = "+workingGroup.master_builder_id.to_s+"
        ")      
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
    @action = "edit"
    @workingGroup = WorkingGroup.find(params[:id])
    @workers = Array.new
    @executors = Array.new
    @front_chiefs = Array.new
    @master_builders = Array.new
    Worker.where("cost_center_id = ? AND position_wg_id IS NULL", get_company_cost_center('cost_center').to_s).each do |wo|
      @workers << wo
    end
    TypeEntity.find_by_preffix("P").entities.each do |executor|
      @executors << executor
    end
    PositionWorker.find_by_name("Jefe de Frente").workers.each do |front_chief|
      @front_chiefs << front_chief
    end
    Worker.where("position_wg_id = "+PositionWorker.find_by_name("Jefe de Frente").id.to_s+" AND cost_center_id=" + get_company_cost_center('cost_center').to_s).each do |wo|
      @front_chiefs << wo
    end
    @front_chiefs = @front_chiefs + @workers
    @front_chiefs = @front_chiefs.uniq
    PositionWorker.find_by_name("Capataz").workers.each do |master_builder|
      @master_builders << master_builder
    end
    Worker.where("position_wg_id = "+PositionWorker.find_by_name("Capataz").id.to_s+" AND cost_center_id=" + get_company_cost_center('cost_center').to_s).each do |wo|
      @master_builders << wo
    end
    @master_builders = @master_builders + @workers
    @master_builders = @master_builders.uniq
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
