class Production::PartPeopleController < ApplicationController
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @company = get_company_cost_center('company')
    cost_center = get_company_cost_center('cost_center')
    #@part_people = PartPerson.where("cost_center_id = ?", cost_center)
    @workinggroup = WorkingGroup.first
    render layout: false
  end

  def show
    @partperson = PartPerson.find(params[:id])
    @partpersondetails = @partperson.part_person_details
    @company = get_company_cost_center('company')
    render layout: false
  end

  def show_part_people
    display_length = params[:iDisplayLength]
    pager_number = params[:iDisplayStart]
    keyword = params[:sSearch]
    array = Array.new
    cost_center = get_company_cost_center('cost_center')

    array = PartPerson.get_part_people(cost_center, display_length, pager_number, keyword)
    render json: { :aaData => array }
  end

  def new
    @partpersonlast = PartPerson.count
    @numbercode = @partpersonlast+1
    @numbercode = @numbercode.to_s.rjust(5,'0')
    @partperson = PartPerson.new
    @working_groups = WorkingGroup.all
    workers = Worker.where("typeofworker LIKE 'obrero' AND state LIKE 'active'")
    @workers = Array.new
    workers.each do |wor|
      if wor.worker_contracts.count != 0
        @workers << wor
      end
    end
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
    if WorkerContract.where("worker_id = ?",@worker.id).count>0
      if WorkerContract.where("worker_id = ?",@worker.id).last.article.nil?
        @category_worker = "No tiene"
      else
        @category_worker = WorkerContract.where("worker_id = ?",@worker.id).last.article.name
      end
    else
      @category_worker = "No tiene"
    end
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
    partperson.update_attributes(part_person_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index, company_id: params[:company_id]
  rescue ActiveRecord::StaleObjectError
      partperson.reload
      flash[:error] = "Alguien más ha modificado los datos en este instante. Intente Nuevamente."
      redirect_to :action => :index
  end

  def destroy
    partperson = PartPerson.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el Grupo de Trabajo."
    render :json => partperson
  end

  private
  def part_person_parameters
    params.require(:part_person).permit(
      :working_group_id, 
      :lock_version, 
      :block, 
      :number_part, 
      :date_of_creation, 
      part_person_details_attributes: [
        :id, 
        :part_person_id, 
        :worker_id, 
        :sector_id, 
        :phase_id, 
        :normal_hours, 
        :he_60, 
        :he_100, 
        :total_hours, 
        :lock_version, 
        :_destroy
      ]
    )
  end
end
