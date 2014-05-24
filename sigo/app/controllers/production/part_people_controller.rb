class Production::PartPeopleController < ApplicationController
  def index
    @company = get_company_cost_center('company')
    @part_people = PartPerson.all
    @workinggroup = WorkingGroup.first
    render layout: false
  end

  def show
    @partperson = PartPerson.find(params[:id])
    @partpersondetails = @partperson.part_person_details
    @company = params[:company_id]
    render layout: false
  end

  def new
    @partperson = PartPerson.new
    @working_groups = WorkingGroup.all
    @workers = Worker.all
    @company = params[:company_id]
    render layout: false
  end

  def create
    partperson = PartPerson.new(part_person_parameters)
    if partperson.save
      flash[:notice] = "Se ha creado correctamente la parte de obra."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      partperson.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def add_more_worker
    @reg_n = Time.now.to_i
    @sectors = Sector.where("code LIKE '__'")
    @phases = Phase.where("code LIKE '__'")
    @worker = Worker.find(params[:worker_id])
    @id_worker = @worker.id
    @name_worker = @worker.first_name + ' ' + @worker.second_name + ' ' + @worker.paternal_surname + ' ' + @worker.maternal_surname
    @category_worker = @worker.category_of_worker.name
    render(partial: 'part_people_items', :layout => false)
  end

  def edit
    @partperson = PartPerson.find(params[:id])
    @reg_n = Time.now.to_i
    @working_groups = WorkingGroup.all
    @sectors = Sector.where("code LIKE '__'")
    @action = 'edit'
    @company = params[:company_id]
    @workers = Worker.all
    render layout: false
  end

  def update
    partperson = PartPerson.find(params[:id])
    if partperson.update_attributes(part_person_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      partperson.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @partperson = partperson
      render :edit, layout: false
    end
  end

  def destroy
    partperson = PartPerson.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el Grupo de Trabajo."
    render :json => partperson
  end

  private
  def part_person_parameters
    params.require(:part_person).permit(:working_group_id, :number_part, :date_of_creation, part_person_details_attributes: [:id, :part_person_id, :worker_id, :sector_id, :phase_id, :normal_hours, :he_60, :he_100, :total_hours, :_destroy])
  end
end
