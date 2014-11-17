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
    @pay = Payslip.new 
    @ingo = Array.new
    @deso = Array.new
    @inge = Array.new
    @dese = Array.new
    @cc = CostCenter.find(get_company_cost_center('cost_center'))
    @ingresos = Concept.where("code LIKE '1%'")
    @descuentos = Concept.where("code LIKE '2%'")
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
    render layout: false
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

  def generate_payroll
    @cc = CostCenter.find(get_company_cost_center('cost_center'))
    company_id = get_company_cost_center('company')
    ing = params[:arregloin]
    des = params[:arreglodes]
    @reg_n = (Time.now.to_f*1000).to_i

    semana = ActiveRecord::Base.connection.execute("
      SELECT *
      FROM weeks_for_cost_center_" + @cc.id.to_s + " wc
      WHERE wc.id = " + params[:semana].to_s).first

    tipo = params[:tipo]

    @max_hour = ActiveRecord::Base.connection.execute("
      SELECT total
      FROM total_hours_per_week_per_cost_center_" + @cc.id.to_s + "
      WHERE status = 1
      AND week_id = " + semana[0].to_s).first

    if !@max_hour.nil?
      @max_hour = @max_hour[0]
    else
      @max_hour = 0
    end

    worker = params[:worker]
    @partes = Array.new

    if worker == "empleado"

      # Future...
      
    elsif worker == "obrero"

      @headers = ['DNI', 'Nombre', 'CAT.', 'C.C', 'ULT. DIA. TRABJ.', 'AFP', 'HIJ', 'HORAS', 'DIAS', 'H.E.S', 'H.FRDO', 'H.E.D']
      @concepts = Concept.select(:id).select(:name).where(:company_id => company_id).where(:status => 1)
      @headers = @headers + @concepts.map(&:name)
      @partes = Payslip.generate_payroll_workers(@cc.id, semana[0], semana[2], semana[3])

    end

    render(partial: 'workers', :layout => false)
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