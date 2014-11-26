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
    puts "--.--------------------------------------------------------------------------------------------------------"
    puts params[:conceptos]
    puts "-----------------------------------------------------------------------------------------------------------"
    oiasnvoabnvbosavboa = 
    pay = Payroll.new(pay_parameters)
    code = Payslip.all.last.code.to_i
    pay.code = (code+1)
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


  def complete_select
    @cc = CostCenter.find(get_company_cost_center('cost_center'))
    semana = ActiveRecord::Base.connection.execute("
      SELECT *
      FROM weeks_for_cost_center_" + @cc.id.to_s + " wc
      WHERE wc.id = " + params[:semana].to_s).first

    tareo = WeeklyWorker.where("start_date = '"+semana[2].to_s+"' AND end_date = '"+semana[3].to_s+"' AND state = 'approved'").first
    if !tareo.nil?
      wg = tareo.working_group.gsub(" ", ",")
    else
      wg = 0
    end
    workers = Array.new
    wo = ActiveRecord::Base.connection.execute("
      SELECT ppd.worker_id, e.dni, CONCAT_WS(' ', e.name, e.second_name, e.paternal_surname, e.maternal_surname)
      FROM part_people pp, part_person_details ppd, entities e, workers w, worker_afps wa, afps af, worker_contracts wc, articles ar
      WHERE pp.cost_center_id = " + @cc.id.to_s + "
      AND ppd.part_person_id = pp.id
      AND pp.date_of_creation BETWEEN '" + semana[2].to_s + "' AND  '" + semana[3].to_s + "'
      AND ppd.worker_id = w.id
      AND pp.working_group_id IN ("+wg.to_s+")
      AND w.entity_id = e.id
      AND wa.worker_id = w.id
      AND af.id = wa.afp_id
      AND wc.worker_id = w.id
      AND wc.article_id = ar.id
      GROUP BY ppd.worker_id
    ")
    wo.each do |wo|
      workers << {'id' => wo[0].to_s, 'name' => wo[1]+"-"+wo[2]}
    end
    render json: {:workers => workers}
  end

  def complete_select
    @cc = CostCenter.find(get_company_cost_center('cost_center'))
    semana = ActiveRecord::Base.connection.execute("
      SELECT *
      FROM weeks_for_cost_center_" + @cc.id.to_s + " wc
      WHERE wc.id = " + params[:semana].to_s).first

    tareo = WeeklyWorker.where("start_date = '"+semana[2].to_s+"' AND end_date = '"+semana[3].to_s+"' AND state = 'approved'").first
    if !tareo.nil?
      wg = tareo.working_group.gsub(" ", ",")
    else
      wg = 0
    end
    workers = Array.new
    wo = ActiveRecord::Base.connection.execute("
      SELECT ppd.worker_id, e.dni, CONCAT_WS(' ', e.name, e.second_name, e.paternal_surname, e.maternal_surname)
      FROM part_people pp, part_person_details ppd, entities e, workers w, worker_afps wa, afps af, worker_contracts wc, articles ar
      WHERE pp.cost_center_id = " + @cc.id.to_s + "
      AND ppd.part_person_id = pp.id
      AND pp.date_of_creation BETWEEN '" + semana[2].to_s + "' AND  '" + semana[3].to_s + "'
      AND ppd.worker_id = w.id
      AND pp.working_group_id IN ("+wg.to_s+")
      AND w.entity_id = e.id
      AND wa.worker_id = w.id
      AND af.id = wa.afp_id
      AND wc.worker_id = w.id
      AND wc.article_id = ar.id
      GROUP BY ppd.worker_id
    ")
    wo.each do |wo|
      workers << {'id' => wo[0].to_s, 'name' => wo[1]+" - "+wo[2]}
    end
    render json: {:workers => workers}
  end

  def add_extra_info
    @worker = Worker.find(params[:worker])
    @concept = Concept.find(params[:concept])
    @amount = params[:amount]
    @reg_n = (Time.now.to_f*1000).to_i
    render(partial: 'extra', :layout => false)
  end

  def complete_select2
    t_wor = params[:worker]
    concepts = Array.new
    if t_wor == "empleado"
      con = Concept.where("status = 1 AND type_empleado = 'Fijo'")
    else
      con = Concept.where("status = 1 AND type_obrero = 'Fijo'")
    end
    con.each do |wo|
      concepts << {'id' => wo.id.to_s, 'name' => wo.code+" - "+wo.name}
    end     
    render json: {:concepts => concepts} 
  end  

  def generate_payroll
    @pay = Payslip.new
    @cc = CostCenter.find(get_company_cost_center('cost_center'))
    company_id = get_company_cost_center('company')
    ing = params[:arregloin]
    des = params[:arreglodes]
    apor = params[:arregloapor]
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
    params.require(:payroll).permit(:worker_id, :cost_center_id, :start_date, :end_date, :days, :normal_hours, :subsidized_day, :subsidized_hour, :last_worked_day, :he_60, :code, :he_100, :concepts_and_amounts, :month)
  end
end