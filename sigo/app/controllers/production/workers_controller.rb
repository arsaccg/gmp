class Production::WorkersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  skip_before_filter  :verify_authenticity_token
  
  def index
    @company = get_company_cost_center('company')
    cost_center = get_company_cost_center('cost_center')
    @article = TypeOfArticle.find_by_code('01').articles.first
    @bank = Bank.first
    @workers = Worker.where("cost_center_id = ?", cost_center)
    @entity = TypeEntity.find_by_name('Trabajadores').entities.first
    @empleados = Worker.where("typeofworker LIKE 'empleado' AND state LIKE 'active' AND cost_center_id ="+cost_center.to_s).count
    @obreros = Worker.where("typeofworker LIKE 'obrero' AND state LIKE 'active' AND cost_center_id ="+cost_center.to_s).count
    @pensionistas = Worker.where("typeofworker LIKE 'pensionista' AND state LIKE 'active' AND cost_center_id ="+cost_center.to_s).count
    @formaciones = Worker.where("typeofworker LIKE 'formacion' AND state LIKE 'active' AND cost_center_id ="+cost_center.to_s).count
    @externos = Worker.where("typeofworker LIKE 'externo' AND state LIKE 'active' AND cost_center_id ="+cost_center.to_s).count
    render layout: false
  end

  def show
    @worker = Worker.find(params[:id])
    @worker_afps = @worker.worker_afps
    @worker_center_of_studies = @worker.worker_center_of_studies
    @worker_details = @worker.worker_details
    @worker_experiences = @worker.worker_experiences
    @worker_familiars = @worker.worker_familiars
    @worker_healths = @worker.worker_healths
    @worker_otherstudies = @worker.worker_otherstudies
    @worker_workdays= TypeWorkdaysWorker.find_by_worker_id(@worker.id)
    if !@worker_workdays.nil?
      @workday= TypeWorkday.find(@worker_workdays.type_workday_id).name.to_s
    else
      @workday = " "
    end
    render layout: false
  end

  def show_workers
    display_length = params[:iDisplayLength]
    typeofworker = params[:typeofworker]
    pager_number = params[:iDisplayStart]
    keyword = params[:sSearch]
    if keyword == 'activo'
      keyword = 'active'
    elsif keyword == 'registrado'
      keyword = 'registered'
    elsif keyword == 'cesado'
      keyword = 'ceased'      
    end
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
    if keyword == 'activo'
      keyword = 'active'
    elsif keyword == 'registrado'
      keyword = 'registered'
    elsif keyword == 'cesado'
      keyword = 'ceased'      
    end
    array = Array.new
    cost_center = get_company_cost_center('cost_center')
    array = Worker.get_workers_empleados(typeofworker,cost_center, display_length, pager_number, keyword)
    render json: { :aaData => array }
  end

  def new
    @entity = Entity.find_by_dni(params[:dni])
    @afp = Afp.all
    @action = "new"
    if @entity.nil?
      @reg_n = Time.now.to_i
      @type_entities = TypeEntity.all
      @entity = Entity.new
      @company_id = params[:company_id]
      @costCenter = Company.find(params[:company_id]).cost_centers
      redirect_to url_for(:controller => "logistics/entities", :action => :new, :company_id => @company_id, :type => 'worker')
    else
      @workerexist = Worker.where("entity_id = " +@entity.id.to_s + " AND cost_center_id = "+ get_company_cost_center('cost_center').to_s).first
      if @workerexist.nil? || (@workerexist.state=="ceased")
        @worker = Worker.new
        @company = params[:company_id]
        @banks = Bank.all
        @afp = Afp.all
        @positionWorkers = PositionWorker.all
        @health = HealthCenter.all
        @years = getyears()
        render layout: false
      else
        flash[:error] =  "El trabajador ya existe y esta activo."
        redirect_to :action => :index
      end
    end
  end

  def display_afps
    @hash = Array.new
    @hash = "<option value=''>Seleccione</option>"
    afp = Afp.where("type_of_afp = ?", params[:type_of_afp])
    afp.each do |afp|
      @hash = @hash + "<option value="+afp.id.to_s+">"+afp.enterprise.to_s+"</option>"
    end
    render :json => { 'hash' => @hash }
  end

  def create
    worker = Worker.new(worker_parameters)
    worker.state
    worker.cost_center_id = get_company_cost_center('cost_center')
    if worker.save
      flash[:notice] = "Se ha creado correctamente el trabajador."
      redirect_to :action => :index, company_id: session[:company]
    else
      worker.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index, company_id: session[:company]
    end
  end

  def edit
    @years2 = getyears()
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
    @years = getyears()
    @register = params[:register]
    render layout: false
  end

  def update
    worker = Worker.find(params[:id])
    worker.update_attributes(worker_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index, company_id: params[:company_id]
  rescue ActiveRecord::StaleObjectError
    worker.reload
    flash[:error] = "Alguien más ha modificado los datos en este instante. Intente Nuevamente."
    redirect_to :action => :index, company_id: params[:company_id]     
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
    @afpnumber = params[:afpnumber]
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
    @years = getyears()
    @years2 = getyears()
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
    @title = params[:title2]
    @salary = params[:salary]
    @bossincharge = params[:bossincharge]
    @exitreason = params[:exitreason]
    @start_date = params[:start_date2]
    @end_date = params[:end_date2]
    @years2 = getyears()
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
      worker = Worker.find(params[:id])
      worker.worker_afps.destroy_all
      worker.worker_center_of_studies.destroy_all
      worker.worker_details.destroy_all
      worker.worker_experiences.destroy_all
      worker.worker_familiars.destroy_all
      worker.worker_healths.destroy_all
      worker.worker_otherstudies.destroy_all
      worker.type_workdays_workers.destroy_all
      worker = Worker.destroy(params[:id])
      flash[:notice] = "Se ha eliminado correctamente el trabajador."
    end
    render :json => worker
  end

  def register
    worker = Worker.find(params[:id])
    if worker.worker_afps.count > 0 || worker.typeofworker=="externo"
      worker.register
      num = ActiveRecord::Base.connection.execute("
          SELECT MAX( CONVERT( number_position, UNSIGNED INTEGER ) ) 
          FROM workers
          WHERE typeofworker =  '"+worker.typeofworker.to_s+"'
          AND number_position IS NOT NULL 
          AND cost_center_id = " + get_company_cost_center('cost_center').to_s + "
          ORDER BY workers.id DESC")
      if  !num.nil?
        worker.update_attributes(:number_position => num.first[0].to_i+1)
      else
        worker.update_attributes(:number_position => 1)
      end
    else
      flash[:error] = "Asegurese que el trabajador tenga una AFP registrada."
    end
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
    worker.update_attributes(:start_date => params[:start_date])
    worker.approve
    if params[:redireccionamiento].to_s == 'inbox'
      redirect_to :root
    else
      redirect_to :action => :index
    end
  end

  def cancel
    worker = Worker.find(params[:id])
    workercontract = WorkerContract.find_by_status(1)
    worker.update_attributes(:end_date=>params[:end_date_2])
    WorkerContract.where( id: workercontract.id ).update_all( end_date_2: params[:end_date_2] , reason_for_termination: params[:reason_for_termination], status: 0, comment: params[:comment] )
    # Save file
    WorkerContract.find(workercontract.id).update_attributes(worker_contract_file_param)
    workercontract.save!
    worker.cancel
    redirect_to :action => :index
  end

  def part_worker
    @worker = Worker.find_by_id(params[:worker_id])
    @workercontract = WorkerContract.find_by_status(1)
    render layout: false
  end

  def part_contract
    cost_center_obj = CostCenter.find(session[:cost_center])
    if WorkerContract.joins(:worker).where(workers: {cost_center_id: cost_center_obj.id.to_s}).order('id ASC').first.nil?
      @worker_contract_correlative = cost_center_obj.code.to_s + ' - ' + 1.to_s.rjust(4, '0')
    else
      @worker_contract_correlative = cost_center_obj.code.to_s + ' - ' + (WorkerContract.joins(:worker).where(workers: {cost_center_id: cost_center_obj.id.to_s}).order('id ASC').count + 1).to_s.rjust(4, '0')
    end
    @typeofcontract = params[:typeofcontract]
    @articles = TypeOfArticle.find_by_code('01').articles
    @contractypes = ContractType.all
    @cost_center = cost_center_obj.id
    @worker = Worker.find_by_id(params[:worker_id])
    @redireccionamiento = params[:redireccionamiento]
    render layout: false
  end

  def list
    render layout: false
  end

  def list_pdf
    @cc = CostCenter.find(get_company_cost_center('cost_center'))
    @type = params[:type].split(',')
    @todo = Array.new
    @typeofworker = Array.new
    @active = Array.new
    @cesado = Array.new
    @abuelo = Array.new
    @padre = Array.new
    @hijo = Array.new
    @abuelo1 = Array.new
    @padre1 = Array.new
    @hijo1 = Array.new
    if params[:state1]!='null'
      @type.each do |ty|
        active = ActiveRecord::Base.connection.execute("
          SELECT ar.code, ar.name, Concat(e.name, ' ', e.second_name, ' ', e.paternal_surname, ' ',e.maternal_surname), e.dni, e.address, concat( e.city, ' - ',e.province, ' - ', e.department)
          FROM articles ar, entities e, workers w, worker_contracts wc
          WHERE w.cost_center_id = "+@cc.id.to_s+"
          AND w.state LIKE '"+params[:state1].to_s+"'
          AND w.typeofworker = '"+ty.to_s+"'
          AND w.entity_id = e.id
          AND wc.status = 1
          AND w.id = wc.worker_id
          AND wc.article_id = ar.id
          ORDER BY ar.code
        ")
        if active.count > 0
          if @active.count==0
            @active << [nil,"Activo",nil,nil,nil,nil]
            @todo << [nil,"Activo",nil,nil,nil,nil]
          end
          active.each do |a|
            if !@typeofworker.include?(ty.to_s)
              @typeofworker << ty.to_s
              @todo << [nil,ty.to_s.capitalize,nil,nil,nil,0]
            end
            @code = a[0].to_s
            if !@abuelo.include?(@code[2,2])
              @abuelo << @code[2,2]
              @todo << [@code[2,2],nil,nil,nil,nil,nil]
            end
            if !@padre.include?(@code[2,4])
              @padre << @code[2,4]
              @todo << [@code[2,4],nil,nil,nil,nil,nil]
            end
            if !@hijo.include?(@code[2,6])
              @hijo << @code[2,6]
              @todo << [@code[2,6],nil,nil,nil,nil,nil]
            end
            @todo << a
          end
        end
      end
    end
    @typeofworker = Array.new
    puts @typeofworker.inspect
    if params[:state2]!='null'
      @type.each do |ty|
        cesado = ActiveRecord::Base.connection.execute("
          SELECT ar.code, ar.name, Concat(e.name, ' ', e.second_name, ' ', e.paternal_surname, ' ',e.maternal_surname), e.dni, e.address, concat(e.city, ' - ',e.province, ' - ', e.department)
          FROM articles ar, entities e, workers w, worker_contracts wc
          WHERE w.cost_center_id = "+@cc.id.to_s+"
          AND w.state LIKE '"+params[:state2].to_s+"'
          AND w.typeofworker = '"+ty.to_s+"'
          AND w.entity_id = e.id
          AND w.id = wc.worker_id
          AND wc.article_id = ar.id
          GROUP BY w.id
        ")
        if cesado.count > 0
          if @cesado.count==0
            @cesado << [nil,"Cesado",nil,nil,nil,nil]
            @todo << [nil,"Cesado",nil,nil,nil,nil]
          end
          cesado.each do |c|
            if !@typeofworker.include?(ty.to_s)
              @typeofworker << ty.to_s
              @todo << [nil,ty.to_s.capitalize,nil,nil,nil,0]
            end
            @code = a[0].to_s
            if !@abuelo1.include?(@code[2,2])
              @abuelo1 << @code[2,2]
              @todo << [@code[2,2],nil,nil,nil,nil,nil]
            end
            if !@padre1.include?(@code[2,4])
              @padre1 << @code[2,4]
              @todo << [@code[2,4],nil,nil,nil,nil,nil]
            end
            if !@hijo1.include?(@code[2,6])
              @hijo1 << @code[2,6]
              @todo << [@code[2,6],nil,nil,nil,nil,nil]
            end
            @todo << c
          end
        end
      end
    end
    @todo.each do |t|
      puts t.inspect
    end
    render :pdf => "reporte_listado_de_trabajadores-#{Time.now.strftime('%d-%m-%Y')}", 
           :template => 'production/workers/report_pdf.pdf.haml',
           :orientation => 'Landscape',
           :page_size => 'A4'
  end  

  def worker_pdf
    @date = Time.now
    @worker = Worker.find(params[:id])
    @company = @worker.cost_center.company
    if @worker.entity.date_of_birth!=nil
      @edad = @date.year - @worker.entity.date_of_birth.year
    else
      @edad = 0
    end
    @worker_afps = @worker.worker_afps
    @nombre = ""
    @afp = WorkerAfp.where("worker_id = ?",params[:id]).last
    if ( !@afp.nil? ) && ( @afp.afp.type_of_afp ) == 'SNP'
      @nombre = "SNP"
    elsif ( !@afp.nil? ) && ( @afp.afp.type_of_afp ) == 'SPP'
      @nombre = "Nombre de AFP"
    else
      @nombre = "TIPO"
    end
    @bank = WorkerDetail.where("worker_id = ?",params[:id]).last
    @worker_center_of_studies = @worker.worker_center_of_studies
    @worker_details = @worker.worker_details
    @worker_experiences = @worker.worker_experiences
    @worker_familiars = @worker.worker_familiars
    @worker_healths = @worker.worker_healths
    @worker_otherstudies = @worker.worker_otherstudies
    @familiars = 1
    @center_of_studies = 1
    @otherstudies = 1
    @experiencies = 1
    if @worker_familiars.count==0
      @familiars = 0
    end
    if @worker_center_of_studies.count==0
      @center_of_studies = 0
    end
    if @worker_otherstudies.count==0
      @otherstudies = 0
    end
    if @worker_experiences.count==0
      @experiencies = 0
    end
    @workercontract = WorkerContract.where("worker_id = ?",params[:id]).last
    prawnto inline: true, :prawn => { :page_size => 'A4', :page_layout => :portrait }

  end

  def getyears
    years = Array.new
    startyear = 1930
    (0..169).each do |something|
      years << startyear
      startyear += 1
    end
    return years
  end

  def complete_sub_category_worker
    tp = Array.new
    type = TypeOfWorker.where("worker_type = '"+params[:tipo]+"'")
    type.each do |wo|
      tp << {'id' => wo.id.to_s, 'name' => wo.name.to_s}
    end
    render json: {:sub_cat => tp}
  end

  def check_contracts
    @quidias = ActiveRecord::Base.connection.execute("
      SELECT DISTINCT CONCAT(e.paternal_surname, ' ', e.maternal_surname, ', ', e.name, ' ', IFNULL(e.second_name,''))
      FROM worker_contracts wc, workers w, entities e
      WHERE wc.end_date_2 IS NULL 
      AND wc.end_date IS NOT NULL
      AND w.cost_center_id = " + get_company_cost_center('cost_center').to_s + "
      AND DATE_SUB( wc.end_date , INTERVAL 15 DAY) = CURDATE()
      AND wc.worker_id = w.id
      AND w.entity_id = e.id
      ")
    @vencido = ActiveRecord::Base.connection.execute("
      SELECT DISTINCT CONCAT(e.paternal_surname, ' ', e.maternal_surname, ', ', e.name, ' ', IFNULL(e.second_name,''))
      FROM worker_contracts wc, workers w, entities e
      WHERE wc.end_date_2 IS NULL 
      AND wc.end_date < CURDATE()
      AND w.cost_center_id = " + get_company_cost_center('cost_center').to_s + "
      AND wc.worker_id = w.id
      AND w.entity_id = e.id
      ")    
    render(partial: 'contract_expire', :layout => false)
  end

  private
  def worker_parameters
    params.require(:worker).permit( 
      :type_of_worker_id, :email, {:type_workday_ids => []}, :onpafp, :lock_version, :driverlicense, :income_fifth_category, :unionized, :disabled, 
      :workday, :numberofchilds, :typeofworker, :maritalstatus,:primarystartdate,:primaryenddate,:highschoolstartdate,
      :highschoolenddate,:levelofinstruction, :lastgrade, :phone, :pais, :address,:cellphone, :quality, :primaryschool, :highschool,
      :primarydistrict, :highschooldistrict,:security, :enviroment,:labor_legislation, :district, :position_worker_id,:province,
      :department, :entity_id, :cv, :antecedent_police, :dni, :cts_deposit_letter, :pension_funds_letter, :affidavit, :marriage_certificate,
      :birth_certificate_of_childer, :dni_wife_kids, :schoolar_certificate,
      worker_details_attributes: [:id, :worker_id, :bank_id, :account_number, :lock_version, :_destroy],
      worker_afps_attributes: [:id, :worker_id, :afp_id, :afpnumber, :afptype, :start_date, :lock_version, :end_date, :_destroy],
      worker_healths_attributes: [:id, :worker_id, :health_center_id, :health_regime, :lock_version, :start_date, :end_date, :_destroy],
      worker_familiars_attributes: [:id, :worker_id, :paternal_surname, :maternal_surname, :lock_version, :names, :relationship, :dayofbirth, :dni, :_destroy],
      worker_center_of_studies_attributes: [:id, :worker_id, :name, :profession, :title, :lock_version, :numberoftuition, :start_date, :end_date, :_destroy],
      worker_otherstudies_attributes: [:id, :worker_id, :study, :lock_version, :level, :_destroy],
      worker_experiences_attributes: [:id, :worker_id, :businessname, :lock_version, :title, :salary, :bossincharge, :exitreason, :start_date, :end_date, :_destroy],
      worker_rent_fifth_category_attributes: [:id, :worker_id, :previous_salary, :rent, :date_last_rent])

  end

  def worker_contract_file_param
    params.require(:worker_contract).permit(:document)
  end
end