class Production::WorkersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @company = get_company_cost_center('company')
    cost_center = get_company_cost_center('cost_center')
    @article = TypeOfArticle.find_by_code('01').articles.first
    @bank = Bank.first
    @workers = Worker.where("cost_center_id = ?", cost_center)
    @entity = TypeEntity.find_by_name('Trabajadores').entities.first
    @empleados = Worker.where("typeofworker LIKE 'empleado' AND state LIKE 'active'").count
    @obreros = Worker.where("typeofworker LIKE 'obrero' AND state LIKE 'active'").count
    @pensionistas = Worker.where("typeofworker LIKE 'pensionista' AND state LIKE 'active'").count
    @formaciones = Worker.where("typeofworker LIKE 'formacion' AND state LIKE 'active'").count
    @externos = Worker.where("typeofworker LIKE 'externo' AND state LIKE 'active'").count
    render layout: false
  end

  def show
    @worker = Worker.find(params[:id])
    render layout: false
  end

  def show_workers
    display_length = params[:iDisplayLength]
    typeofworker = params[:typeofworker]
    pager_number = params[:iDisplayStart]
    keyword = params[:sSearch]
    array = Array.new
    cost_center = get_company_cost_center('cost_center')
    array = Worker.get_workers(typeofworker,cost_center, display_length, pager_number, keyword)
    render json: { :aaData => array }
  end

  def show_workers_empleados
    display_length = params[:iDisplayLength]
    typeofworker = params[:typeofworker]
    pager_number = params[:iDisplayStart]
    keyword = params[:sSearch]
    array = Array.new
    cost_center = get_company_cost_center('cost_center')
    array = Worker.get_workers_empleados(typeofworker,cost_center, display_length, pager_number, keyword)
    render json: { :aaData => array }
  end

  def new
    @entity = Entity.find_by_dni(params[:dni])
    @action = "new"
    if @entity.nil?
      @reg_n = Time.now.to_i
      @type_entities = TypeEntity.all
      @entity = Entity.new
      @company_id = params[:company_id]
      @costCenter = Company.find(params[:company_id]).cost_centers
      redirect_to url_for(:controller => "logistics/entities", :action => :new, :company_id => @company_id, :type => 'worker')
    else
      @workerexist = Worker.find_by_entity_id(@entity.id)
      if @workerexist.nil? || (@workerexist.state=="ceased")
        @worker = Worker.new
        @company = params[:company_id]
        @banks = Bank.all
        @afp = Afp.all
        @positionWorkers = PositionWorker.all
        @health = HealthCenter.all
        render layout: false
      else
        flash[:error] =  "El trabajador ya existe y esta activo."
        redirect_to :action => :index
      end
    end
  end

  def create
    worker = Worker.new(worker_parameters)
    worker.state
    worker.cost_center_id = get_company_cost_center('cost_center')
    if worker.save
      flash[:notice] = "Se ha creado correctamente el trabajador."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      worker.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def edit
    @worker = Worker.find(params[:id])
    @banks = Bank.all
    @afp = Afp.all
    @health = HealthCenter.all
    @reg_n = Time.now.to_i
    @positionWorkers = PositionWorker.all
    @entity = Entity.find(Worker.find(params[:id]).entity_id)
    @entities = TypeEntity.find_by_name('Trabajadores').entities
    @entites = TypeEntity.find_by_name('Trabajadores').entities
    @company = params[:company_id]
    @action = 'edit'
    @register = params[:register]
    render layout: false
  end

  def update
    worker = Worker.find(params[:id])
    if worker.update_attributes(worker_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      worker.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @worker = worker
      render :edit, layout: false
    end
  end

  def add_worker_item_field
    @reg_n = ((Time.now.to_f)*100).to_i
    data_bank_unit = params[:bank_id].split('-')
    @bank = Bank.find(data_bank_unit[0])
    @account_number = params[:account_number].to_s
    @business_name_bank, @id_bank = @bank.business_name, @bank.id
    render(partial: 'worker_items', :layout => false)
  end

  def add_afp_item_field
    @reg_n = ((Time.now.to_f)*100).to_i
    @afp = Afp.find(params[:afp_id])
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @enterprise, @id_afp = @afp.enterprise, @afp.id
    @afptype = params[:afptype]
    render(partial: 'afp_items', :layout => false)
  end

  def add_health_center_item_field
    @reg_n = ((Time.now.to_f)*100).to_i
    @health_regime = params[:health_regime]
    if (params[:health_regime]!="ESSALUD REGULAR (Exclusivamente)")
      @health = HealthCenter.find(params[:health_center_id])
      @enterprise, @id_health_center = @health.enterprise, @health.id
    else
      @enterprise, @id_health_center = "", ""
    end
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    render(partial: 'health_items', :layout => false)
  end

  def add_familiar_item_field
    @reg_n = ((Time.now.to_f)*100).to_i
    @paternal_surname = params[:paternal_surname]
    @maternal_surname = params[:maternal_surname]
    @names = params[:names]
    @relationship = params[:relationship]
    @dayofbirth = params[:dayofbirth]
    @dni = params[:dni]
    render(partial: 'familiar_items', :layout => false)
  end

  def add_centerofstudy_item_field
    @reg_n = ((Time.now.to_f)*100).to_i
    @name = params[:nameu]
    @profession = params[:profession]
    @title = params[:title]
    @numberoftuition = params[:numberoftuition]
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    render(partial: 'centerofstudy_items', :layout => false)
  end

  def add_otherstudy_item_field
    @reg_n = ((Time.now.to_f)*100).to_i
    @study = params[:study]
    @level = params[:level]
    render(partial: 'otherstudy_items', :layout => false)
  end

  def add_experience_item_field
    @reg_n = ((Time.now.to_f)*100).to_i
    @businessname = params[:businessname]
    @businessaddress = params[:businessaddress]
    @title = params[:title2]
    @salary = params[:salary]
    @bossincharge = params[:bossincharge]
    @exitreason = params[:exitreason]
    @start_date = params[:start_date2]
    @end_date = params[:end_date2]
    render(partial: 'experience_items', :layout => false)
  end

  def destroy
    delete = 0
    partofequip = PartOfEquipment.where('worker_id = ?',params[:id])
    partofequip.each do |del|
      delete +=1
    end
    workinggroup = WorkingGroup.where('master_builder_id = ? OR front_chief_id = ?',params[:id],params[:id])
    workinggroup.each do |del|
      delete +=1
    end
    partpersondetail = PartPersonDetail.where('worker_id = ?',params[:id])
    partpersondetail.each do |del|
      delete +=1
    end
    stockinput = StockInput.where('responsible_id = ?',params[:id])
    stockinput.each do |del|
      delete +=1
    end
    if delete > 0
      flash[:error] = "No se puede eliminar al trabajador."
      worker = 'true'
    else
      flash[:notice] = "Se ha eliminado correctamente el trabajador."
      worker = Worker.destroy(params[:id])
    end
    render :json => worker
  end

  def register
    worker = Worker.find(params[:id])
    worker.register
    puts "YES"
    redirect_to :action => :index
  end

  def approve
    workercontract = WorkerContract.new
    workercontract.article_id = params[:article_id]
    workercontract.camp = params[:camp]
    workercontract.destaque = params[:destaque]
    workercontract.salary = params[:salary]
    workercontract.regime = params[:regime]
    workercontract.bonus = params[:bonus]
    workercontract.viatical = params[:viatical]
    workercontract.days = params[:days]
    workercontract.start_date = params[:start_date]
    workercontract.end_date = params[:end_date]
    workercontract.end_date_2 = params[:end_date]
    workercontract.numberofcontract = params[:numberofcontract]
    workercontract.typeofcontract = params[:typeofcontract]
    workercontract.contract_type_id = params[:contract_type_id]
    workercontract.worker_id = params[:worker_id]
    workercontract.status = 1
    workercontract.save
    worker = Worker.find(params[:worker_id])
    worker.approve
    redirect_to :action => :index
  end

  def cancel
    worker = Worker.find(params[:id])
    workercontract = WorkerContract.where("worker_id = ?",params[:id]).last
    WorkerContract.where( id: workercontract.id ).update_all( end_date_2: params[:end_date_2] , reason_for_termination: params[:reason_for_termination] )
    worker.cancel
    redirect_to :action => :index
  end

  def part_worker
    @worker = Worker.find_by_id(params[:worker_id])
    @workercontract = WorkerContract.where("worker_id = ?",params[:worker_id]).last
    render layout: false
  end

  def part_contract
    @typeofcontract = params[:typeofcontract]
    @articles = TypeOfArticle.find_by_code('01').articles
    @contractypes = ContractType.all
    @cost_center = session[:cost_center]
    @worker = Worker.find_by_id(params[:worker_id])
    render layout: false
  end

  private
  def worker_parameters
    params.require(:worker).permit(:email, {:type_workday_ids => []}, :afpnumber, :driverlicense, :income_fifth_category, :unionized, :disabled, :workday, :numberofchilds, :typeofworker, :maritalstatus,:primarystartdate,:primaryenddate,:highschoolstartdate,:highschoolenddate,:levelofinstruction, :phone, :pais, :address,:cellphone, :quality, :primaryschool, :highschool,:primarydistrict, :highschooldistrict,:security, :enviroment,:labor_legislation, :district, :position_worker_id,:province, :department, :entity_id, :cv, :antecedent_police, :dni, :cts_deposit_letter, :pension_funds_letter, :affidavit, :marriage_certificate, :birth_certificate_of_childer, :dni_wife_kids, :schoolar_certificate, worker_details_attributes: [:id, :worker_id, :bank_id, :account_number, :_destroy], worker_afps_attributes: [:id, :worker_id, :afp_id, :afptype, :start_date, :end_date, :_destroy], worker_healths_attributes: [:id, :worker_id, :health_center_id, :health_regime, :start_date, :end_date, :_destroy], worker_familiars_attributes: [:id, :worker_id, :paternal_surname, :maternal_surname, :names, :relationship, :dayofbirth, :dni, :_destroy], worker_center_of_studies_attributes: [:id, :worker_id, :name, :profession, :title, :numberoftuition, :start_date, :end_date, :_destroy], worker_otherstudies_attributes: [:id, :worker_id, :study, :level, :_destroy], worker_experiences_attributes: [:id, :worker_id, :businessname, :businessaddress, :title, :salary, :bossincharge, :exitreason, :_destroy])
  end
end