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
    @partworkerdetails = ActiveRecord::Base.connection.execute("SELECT pwd.id, CONCAT( e.paternal_surname,  ' ', e.maternal_surname,  ', ', e.name ) AS name
      FROM part_worker_details pwd, entities e, workers w
      WHERE pwd.part_worker_id =" + @partworker.id.to_s+ "
      AND pwd.worker_id = w.id
      AND e.id = w.entity_id
      ORDER BY name")
    @company = get_company_cost_center('company')
    render layout: false
  end

  def show_part_workers
    display_length = params[:iDisplayLength]
    pager_number = params[:iDisplayStart]
    keyword = params[:sSearch]
    array = Array.new
    cost_center = get_company_cost_center('cost_center')

    array = PartWorker.get_part_workers(cost_center, display_length, pager_number, keyword)
    render json: { :aaData => array }
  end

  def new
    @action = 'new'
    @partworkerlast = PartWorker.count
    @numbercode = @partworkerlast+1
    @numbercode = @numbercode.to_s.rjust(5,'0')
    @partworker = PartWorker.new
    @working_groups = WorkingGroup.all
    @sectors = Sector.where("code LIKE '____'")
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center'))    
    @cc = get_company_cost_center('cost_center')
    render layout: false
  end

  def create
    partworker = PartWorker.new(part_worker_parameters)
    partworker.cost_center_id = get_company_cost_center('cost_center')
    previo = PartWorker.where("date_of_creation = '"+params[:part_worker]['date_of_creation'].to_s+"' AND cost_center_id = "+get_company_cost_center('cost_center').to_s)
    if previo.count == 0
      if partworker.save
        flash[:notice] = "Se ha creado correctamente la parte de obra."
        redirect_to :action => :index
      else
        partworker.errors.messages.each do |attribute, error|
          puts error.to_s
          puts error
        end
        flash[:error] =  "Ha ocurrido un error en el sistema."
        redirect_to :action => :index
      end
    else
      partworker.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ya hay un parte registrado con el mismo día"
      redirect_to :action => :index
    end
  end

  def edit
    @partworker = PartWorker.find(params[:id])
    @reg_n = Time.now.to_i
    @numbercode = @partworker.number_part
    @workers = Worker.where("typeofworker LIKE 'empleado' AND state LIKE 'active'")
    @working_groups = WorkingGroup.all
    @sectors = Sector.where("code LIKE '__'")
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center'))
    @costcenters = CostCenter.where("company_id = ?",@company)
    @action = 'edit'
    @company = get_company_cost_center('company')
    @workers = Worker.all
    @cc = get_company_cost_center('cost_center')
    render layout: false
  end

  def update
    partworker = PartWorker.find(params[:id])
    if partworker.update_attributes(part_worker_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: session[:company]
    else
      partworker.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @partworker = partworker
      render :edit, layout: false
    end
  end

  def destroy
    partworker = PartWorker.find(params[:id])
    partworker.part_worker_details.destroy_all
    partworker_destroyed = PartWorker.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el Parte de Trabajadores."
    render :json => partworker
  end

  def get_workers
    @phase = params[:phase].to_i
    @sector = params[:sector].to_i
    @wg = params[:wg].to_i
    date = params[:date].to_s
    @company = session[:company]
    @working_groups = WorkingGroup.all
    @reg_n = ((Time.now.to_f)*100).to_i
    @workers = ActiveRecord::Base.connection.execute("
      SELECT DISTINCT w.id
      FROM workers w, entities e, worker_contracts wc
      WHERE w.typeofworker LIKE  'empleado'
      AND w.state LIKE  'active'
      AND w.cost_center_id = " + get_company_cost_center('cost_center').to_s + "
      AND e.id = w.entity_id
      AND w.id = wc.worker_id
      AND wc.start_date <=  '#{date}'
      AND wc.end_date >=  '#{date}'
      ORDER BY CONCAT( e.paternal_surname,  ' ', e.maternal_surname,  ' ', e.name,  ' ', e.second_name ) 
      ")
    @sectors = Sector.where("code LIKE '__'")
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center'))
    @costcenters = CostCenter.where("company_id = ?",@company)
    @cc = get_company_cost_center('cost_center')
    render(partial: "workers", layout: false)    
    
  end

  private
  def part_worker_parameters
    params.require(:part_worker).permit(:number_part, :date_of_creation, part_worker_details_attributes: [:id, :part_worker_id, :cost_center_id, :worker_id, :working_group_id, :reason_of_lack, :sector_id, :phase_id, :assistance, :he_25, :he_35, :_destroy])
  end
end