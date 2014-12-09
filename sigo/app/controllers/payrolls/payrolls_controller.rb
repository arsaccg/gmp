class Payrolls::PayrollsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @payslips = Payslip.select(:week).select(:code).select(:id).group(:week)
    render layout: false
  end

  def show_workers
    array = Array.new
    index = 1
    Payslip.where(:code => params[:w]).each do |payslip|
      entity = payslip.worker.entity
      array << [index, entity.dni.to_s, entity.name.to_s + ' ' + entity.second_name.to_s, entity.paternal_surname.to_s, entity.maternal_surname.to_s, "<a class='btn btn-success btn-xs' href='/payrolls/payrolls/" + payslip.worker.id.to_s + "/generate_payroll.pdf' target='_blank'> Generar boleta de pago </a>"]
      index += 1
    end
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
    /@pay = Payroll.new 
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
    render layout: false/
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

  def generate_payroll
    worker_id = params[:id]
    @total_concepts = Array.new
    @cost_center = CostCenter.find(get_company_cost_center('cost_center'))
    @payslip = Payslip.find_by_worker_id(worker_id)
    @worker = Worker.find(worker_id)
    @worker_contract = @worker.worker_contracts.where(:status => 1).first
    @type_worker = Article.select(:name).select(:code).find(@worker_contract.article_id)
    @category_worker = Category.select(:name).find_by_code(@type_worker.code[2..5])

    week_id = ActiveRecord::Base.connection.execute("SELECT id FROM weeks_for_cost_center_#{@cost_center.id} WHERE name LIKE '%#{@payslip.week.split(':')[0]}%'").first[0]

    total_hour_week = WeeksPerCostCenter.get_total_hours_per_week(@cost_center.id, week_id)
    if @payslip.normal_hours.to_f >= total_hour_week.to_f
      @number_hours_normal = 6
    else
      @number_hours_normal = (@payslip.days.to_f*6/total_hour_week).round()
    end

    @incomes_and_amounts = JSON.parse(@payslip.ing_and_amounts).to_a
    @total_concepts << @incomes_and_amounts.pop
    @discounts_and_amounts = JSON.parse(@payslip.des_and_amounts).to_a
    @total_concepts << @discounts_and_amounts.pop
    @contributions_and_amounts = JSON.parse(@payslip.aport_and_amounts).to_a
    @total_concepts << @contributions_and_amounts.pop

    respond_to do |format|
      format.html
      format.pdf do
        render :pdf => "boleta_de_pago-#{Time.now.strftime('%d-%m-%Y')}", 
               :template => 'payrolls/payrolls/payroll.pdf.haml',
               :orientation => 'Landscape',
               :page_size => 'Letter'
      end
    end

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