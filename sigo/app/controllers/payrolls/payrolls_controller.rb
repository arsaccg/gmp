class Payrolls::PayrollsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @pay = Payroll.all
    @ids = Array.new
    contracts = WorkerContract.where("start_date < '"+Time.now.strftime("%YYYY-%mm-%dd").to_s+"' AND end_date > '"+Time.now.strftime("%YYYY-%mm-%dd").to_s+"'")
    contracts.each do |con|
      @ids << con.worker_id
    end
    @ids = @ids.join(',')
    render layout: false
  end

  def show_workers
    display_length = params[:iDisplayLength]
    pager_number = params[:iDisplayStart]
    keyword = params[:sSearch]
    array = Array.new
    cost_center = get_company_cost_center('cost_center')
    array = Payroll.show_w(cost_center, display_length, pager_number, keyword)
    render json: { :aaData => array }
  end

  def add_concept
    @concept = params[:concept]
    @amount = params[:amount]
    @type = params[:type]
    @reg_n = (Time.now.to_f*1000).to_i
    render(partial: 'concept_items', :layout => false)
  end

  def show
    @pay = Payroll.find_by_worker_id(params[:id])
    @type = params[:type]
    if !@pay.nil?
      @payroll_details = @pay.payroll_details
    end
    @worker = Worker.find(params[:id])
    @entity =Entity.find(@worker.entity_id)
    render layout: false
  end

  def new
    @pay = Payroll.new 
    @ing = Array.new
    @des = Array.new
    @worker = Worker.find(params[:worker_id])
    @entity =Entity.find(@worker.entity_id)
    @ingresos = Concept.where("code LIKE '1%' AND type_obrero = 'Fijo'")
    @descuentos = Concept.where("code LIKE '2%' AND type_obrero = 'Fijo'")
    @ingresos.each do |ing|
      @ing << ing.id.to_s
    end
    @descuentos.each do |des|
      @des << des.id.to_s
    end
    render layout: false
  end

  def display_worker
    word = params[:q]
    article_hash = Array.new
    @name = get_company_cost_center('cost_center')
    worker = Payroll.getWorker(word, @name)
    @worker_hash = Array.new
    worker.each do |art|
      @worker_hash << {'id' => art[0].to_s, 'name' => art[1].to_s+" " + art[2].to_s+" " + art[3].to_s+" "+ art[4].to_s}
    end
    render json: {:worker => @worker_hash}
  end

  def get_info
    entity = Entity.find(params[:worker_id])
    wor = Worker.find_by_entity_id(entity.id)
    WorkerDetail.where("worker_id = "+ wor.id.to_s).each do |wwd|
      @acc = wwd.account_number.to_s
    end
    worker = Array.new
    worker[0] =  entity.name.to_s + " "+ entity.second_name.to_s+ " "+entity.paternal_surname.to_s + " " +entity.maternal_surname.to_s
    worker[1] = entity.dni.to_s
    worker[2] = wor.address.to_s
    worker[3] = entity.date_of_birth.to_s
    worker[4] = entity.gender.to_s
    worker[5] = wor.numberofchilds.to_s
    worker[6] = wor.maritalstatus.to_s
    worker[7] = @acc
    if wor.afp_id != nil
      worker[8] = Afp.find(wor.afp_id.to_s).enterprise.to_s
    else
      worker[8] = " "
    end
    worker[9] = wor.afptype.to_s
    worker[10] = wor.afpnumber.to_s
    worker[11] = wor.position_worker.name
    worker[12] = wor.article.name
    render json: {:worker=>worker}  
  end

  def get_cc
    @cc = Company.find(params[:company]).cost_centers
    render json: {:cc=>@cc}  
  end

  def create
    flash[:error] = nil
    pay = Payroll.new(pay_parameters)
    pay.status = 1
    if pay.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      pay.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @pay = pay
      render :new, layout: false 
    end
  end

  def edit
    @pay = Payroll.find_by_worker_id(params[:id])
    @ing = Array.new
    @des = Array.new
    @worker = Worker.find(params[:id])
    @entity =Entity.find(@worker.entity_id)
    @ingresos = Concept.where("code LIKE '1%' AND type_concept = 'Fijo'")
    @descuentos = Concept.where("code LIKE '2%' AND type_concept = 'Fijo'")
    @ingresos.each do |ing|
      @ing << ing.id.to_s
    end
    @descuentos.each do |des|
      @des << des.id.to_s
    end    
    @action = 'edit'
    @reg_n = (Time.now.to_f*1000).to_i
    render layout: false
  end

  def update
    pay = Payroll.find(params[:id])
    if pay.update_attributes(pay_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      pay.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @pay = pay
      render :edit, layout: false
    end
  end

  def destroy
    pay = Payroll.find(params[:id])
    ActiveRecord::Base.connection.execute("
          UPDATE payrolls SET
          status = 0
          WHERE id = "+pay.id.to_s+"
        ")
    render :json => pay
  end

  private
  def pay_parameters
    params.require(:payroll).permit(:worker_id, 
      payroll_details_attributes: [
        :id, 
        :payroll_id, 
        :concept_id, 
        :amount, 
        :type_con,
        :_destroy
      ] )
  end
end