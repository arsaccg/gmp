class Payrolls::PayslipsController < ApplicationController
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
     
    @ingo = Array.new
    @deso = Array.new
    @inge = Array.new
    @dese = Array.new
    @apo = Array.new
    @ape = Array.new
    @cc = CostCenter.find(get_company_cost_center('cost_center'))
    @ingresos = Concept.where("code LIKE '1%' AND status = 1")
    @descuentos = Concept.where("code LIKE '2%' AND status = 1")
    @aportacion = Concept.where("code LIKE '3%' AND status = 1")

    @afp = Afp.all
    @semanas = ActiveRecord::Base.connection.execute("
      SELECT *
      FROM weeks_for_cost_center_" + @cc.id.to_s)

    @ingresos.each do |ing|
      if ing.type_obrero == "Fijo"
        @ingo << ing.id.to_s
      elsif ing.type_empleado == "Fijo"
        @inge << ing.id.to_s
      end
    end

    @descuentos.each do |des|
      if des.type_obrero == "Fijo"
        @deso << des.id.to_s
      elsif des.type_empleado == "Fijo"
        @dese << des.id.to_s
      end
    end

    @aportacion.each do |des|
      if des.type_obrero == "Fijo"
        @apo << des.id.to_s
      elsif des.type_empleado == "Fijo"
        @ape << des.id.to_s
      end
    end    
    render layout: false
  end

  def create
    flash[:error] = nil
    regs = params[:regs].split(' ')
    lacode = Payslip.all.last
    if lacode.nil?
      lacode = 0
    else
      lacode = lacode.code.to_i
    end
    flag = false
    regs.each do |pay|
      params2 = params[:payslip][""+pay.to_s+""]
      pay = Payslip.new()
      pay.worker_id = params2['worker_id'].to_s
      pay.cost_center_id = params2['cost_center_id'].to_s
      pay.start_date = params2['start_date'].to_s
      pay.end_date = params2['end_date'].to_s
      pay.days = params2['days'].to_s
      pay.normal_hours = params2['normal_hours'].to_s
      pay.subsidized_day = params2['subsidized_day'].to_s
      pay.subsidized_hour = params2['subsidized_hour'].to_s
      pay.last_worked_day = params2['last_worked_day'].to_s
      pay.he_60 = params2['he_60'].to_s
      pay.code = params2['code'].to_s
      pay.he_100 = params2['he_100'].to_s
      pay.concepts_and_amounts = params2['concepts_and_amounts'].to_s      
      pay.code = (lacode+1).to_s
      if pay.save
        flag = true
      else
        pay.errors.messages.each do |attribute, error|
          puts flash[:error].to_s + error.to_s + "  "
        end
        @pay = pay
        render :new, layout: false 
      end
    end
    redirect_to :action => :index
  end

  def edit
    @pay = Payroll.find_by_worker_id(params[:id])
    @ing = Array.new
    @des = Array.new
    @worker = Worker.find(params[:id])
    @entity =Entity.find(@worker.entity_id)
    @ingresos = Concept.where("code LIKE '1%' AND type_concept = 'Fijo' AND status = 1")
    @descuentos = Concept.where("code LIKE '2%' AND type_concept = 'Fijo' AND status = 1")
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

  def generate_payroll
    @pay = Payslip.new
    @cc = CostCenter.find(get_company_cost_center('cost_center'))
    company_id = get_company_cost_center('company')
    ing = params[:arregloin]
    des = params[:arreglodes]
    apor = params[:arregloapor]
    @reg_n = (Time.now.to_f*1000).to_i
    @reg_n2 = (Time.now.to_f*4212).to_i

    semana = ActiveRecord::Base.connection.execute("
      SELECT *
      FROM weeks_for_cost_center_" + @cc.id.to_s + " wc
      WHERE wc.id = " + params[:semana].to_s).first

    tipo = params[:tipo]
    @start_date = semana[2].to_s
    @end_date = semana[3].to_s
    @max_hour = ActiveRecord::Base.connection.execute("
      SELECT total
      FROM total_hours_per_week_per_cost_center_" + @cc.id.to_s + "
      WHERE status = 1
      AND week_id = " + semana[0].to_s).first

    if !@max_hour.nil?
      @max_hour = @max_hour[0]
    else
      @max_hour = 48
    end

    worker = params[:worker]
    @partes = Array.new

    if worker == "empleado"

      # Future...
      
    elsif worker == "obrero"
      tareo = WeeklyWorker.where("start_date = '"+semana[2].to_s+"' AND end_date = '"+semana[3].to_s+"' AND state = 'approved'").first
      if !tareo.nil?
        wg = tareo.working_group.gsub(" ", ",")
      else
        wg = 0
      end
          
      @headers = ['DNI', 'Nombre', 'CAT.', 'C.C', 'ULT. DIA. TRABJ.', 'AFP', 'HIJ', 'HORAS', 'DIAS', 'H.E.S', 'H.FRDO', 'H.E.D']
      if wg != 0
        @partes = Payslip.generate_payroll_workers(@cc.id, semana[0], semana[2], semana[3], wg, ing, des, apor, @headers)
        @mensaje = "exito"
      else
        @mensaje = "fuentes"
      end
    end
    render(partial: 'workers', :layout => false)
  end

  def destroy
    pay = Payroll.find(params[:id])
    pay.destroy
    render :json => pay
  end

  private
  def pay_parameters
    params.require(:payslip).permit(:worker_id, :cost_center_id, :start_date, :end_date, :days, :normal_hours, :subsidized_day, :subsidized_hour, :last_worked_day, :he_60, :code, :he_100, :concepts_and_amounts, :month)
  end
end