class Administration::PartWorkersController < ApplicationController
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @company = get_company_cost_center('company')
    cost_center = get_company_cost_center('cost_center')
    @workinggroup = WorkingGroup.first
    render layout: false
  end

  def show
    @partworker = PartWorker.find(params[:id])
    @partworkerdetails = @partworker.part_worker_details
    @company = get_company_cost_center('company')
    render layout: false
  end

  def show_part_workers
    display_length = params[:iDisplayLength]
    pager_number = params[:iDisplayStart]
    keyword = params[:sSearch]
    array = Array.new
    company = get_company_cost_center('company')

    array = PartPerson.get_part_people(company, display_length, pager_number, keyword)
    render json: { :aaData => array }
  end

  def new
    @partworkerlast = PartWorker.count
    @numbercode = @partworkerlast+1
    @numbercode = @numbercode.to_s.rjust(5,'0')
    @partworker = PartWorker.new
    @working_groups = WorkingGroup.all
    @workers = Worker.where("typeofworker LIKE 'empleado'")
    @company = params[:company_id]
    render layout: false
  end

  def create
    partperson = PartPerson.new(part_person_parameters)
    partperson.cost_center_id = get_company_cost_center('cost_center')
    partperson.block = 0
    partperson.blockweekly = 0
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
    @reg_n = ((Time.now.to_f)*100).to_i
    @sectors = Sector.where("code LIKE '__'")
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center'))
    @worker = Worker.find(params[:worker_id])
    @id_worker = @worker.id
    @name_worker = @worker.entity.name.to_s + ' ' + @worker.entity.second_name.to_s + ' ' + @worker.entity.paternal_surname.to_s + ' ' + @worker.entity.maternal_surname.to_s
    @category_worker = @worker.article.name
    render(partial: 'part_people_items', :layout => false)
  end

  def edit
    @partperson = PartPerson.find(params[:id])
    @reg_n = Time.now.to_i
    @numbercode = @partperson.number_part
    @working_groups = WorkingGroup.all
    @sectors = Sector.where("code LIKE '__'")
    @action = 'edit'
    @company = get_company_cost_center('company')
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
    params.require(:part_person).permit(:working_group_id, :block, :number_part, :date_of_creation, part_person_details_attributes: [:id, :part_person_id, :worker_id, :sector_id, :phase_id, :normal_hours, :he_60, :he_100, :total_hours, :_destroy])
  end
end
