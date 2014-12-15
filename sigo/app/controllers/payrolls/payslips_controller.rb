class Payrolls::PayslipsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @pay = ActiveRecord::Base.connection.execute("SELECT code, week, month FROM payslips GROUP BY code")
    render layout: false
  end

  def show
    @pay = Payslip.where("code = ?",params[:id])
    if @pay.first.week.nil?
      @type = "month"
    else
      @type = "week"
    end
    render layout: false
  end

  def new
    @tpay = TypeOfPayslip.all
    @cc = CostCenter.find(get_company_cost_center('cost_center'))
    @afp = Afp.all
    @semanas = ActiveRecord::Base.connection.execute("
      SELECT *
      FROM weeks_for_cost_center_" + @cc.id.to_s)
    render layout: false
  end

  def create
    flash[:error] = nil
    a = Payslip.all.last
    
    last_code = 1
    if !a.nil?
      last_code = a.code.to_i + 1 
    end
    regs = params[:regs].split(' ')
    regsEx = params[:regsEx].split(' ')
    regs.each do |reg|
      pay = Payslip.new
      pay.worker_id = params[:payslip][''+reg.to_s+'']['worker_id']
      pay.cost_center_id = params[:payslip][''+reg.to_s+'']['cost_center_id']
      pay.company_id = params[:payslip][''+reg.to_s+'']['company_id']
      pay.week = params[:payslip][''+reg.to_s+'']['week']
      pay.days = params[:payslip][''+reg.to_s+'']['days']
      pay.month = params[:payslip][''+reg.to_s+'']['month']
      pay.normal_hours = params[:payslip][''+reg.to_s+'']['normal_hours']
      pay.subsidized_day = params[:payslip][''+reg.to_s+'']['subsidized_day']
      pay.subsidized_hour = params[:payslip][''+reg.to_s+'']['subsidized_hour']
      pay.last_worked_day = params[:payslip][''+reg.to_s+'']['last_worked_day']
      pay.he_60 = params[:payslip][''+reg.to_s+'']['he_60']
      pay.code = last_code
      pay.he_100 = params[:payslip][''+reg.to_s+'']['he_100']
      pay.ing_and_amounts = params[:payslip][''+reg.to_s+'']['ing_and_amounts'].to_json
      pay.month = params[:payslip][''+reg.to_s+'']['month']
      pay.des_and_amounts = params[:payslip][''+reg.to_s+'']['des_and_amounts'].to_json
      pay.aport_and_amounts = params[:payslip][''+reg.to_s+'']['aport_and_amounts'].to_json
      if pay.save
        flash[:notice] = "Se ha creado correctamente."
      else
        pay.errors.messages.each do |attribute, error|
          puts flash[:error].to_s + error.to_s + "  "
        end
        @pay = pay
        render :new, layout: false 
      end
    end

    ActiveRecord::Base.connection.execute("DELETE FROM extra_information_for_payslips WHERE week = '"+params[:extra_information_for_payslip][''+regsEx.first.to_s+'']['week'].to_s+"'" )
    regsEx.each do |reg|
      extra = ExtraInformationForPayslip.new
      extra.worker_id = params[:extra_information_for_payslip][''+reg.to_s+'']['worker_id']
      extra.concept_id = params[:extra_information_for_payslip][''+reg.to_s+'']['concept_id']
      extra.week = params[:extra_information_for_payslip][''+reg.to_s+'']['week']
      extra.amount = params[:extra_information_for_payslip][''+reg.to_s+'']['amount']
      if extra.save
        flash[:notice] = "Se ha creado correctamente."
      else
        extra.errors.messages.each do |attribute, error|
          puts flash[:error].to_s + error.to_s + "  "
        end
        @extra = extra
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

  def complete_select
    workers = Array.new
    if params[:worker] == "empleado"
      fecha = params[:semana].split('-')
      inicio = fecha[1]+"-"+fecha[0]+"-01"
      d = Date.new(fecha[1].to_i,fecha[0].to_i)
      d +=42
      d = (Date.new(d.year, d.month) - 1).strftime('%Y-%m-%d')
      wo = ActiveRecord::Base.connection.execute("
        SELECT ppd.worker_id, e.dni, CONCAT_WS(  ' ', e.name, e.second_name, e.paternal_surname, e.maternal_surname )
        FROM part_workers pp, part_worker_details ppd, entities e, workers w, worker_afps wa, afps af, worker_contracts wc, articles ar
        WHERE pp.company_id = "+get_company_cost_center('company').to_s+"
        AND ppd.part_worker_id = pp.id
        AND ppd.assistance =  'si'
        AND pp.date_of_creation BETWEEN '" + inicio.to_s + "' AND  '" + d.to_s + "'
        AND ppd.worker_id = w.id
        AND w.entity_id = e.id
        AND wa.worker_id = w.id
        AND af.id = wa.afp_id
        AND wc.worker_id = w.id
        AND wc.article_id = ar.id
        AND wc.status = 1
        GROUP BY w.id"
      )
      wo.each do |wo|
        workers << {'id' => wo[0].to_s, 'name' => wo[1]+" - "+wo[2]}
      end
    else
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
    end
    render json: {:workers => workers}
  end

  def add_extra_info
    fecha = params[:semana].split('-')
    if fecha.length == 2
      case fecha[0].to_i
      when 1
        @week = "Enero - " + fecha[1].to_s
      when 2
        @week = "Febrero - " + fecha[1].to_s
      when 3
        @week = "Marzo - " + fecha[1].to_s
      when 4
        @week = "Abril - " + fecha[1].to_s
      when 5
        @week = "Mayo - " + fecha[1].to_s
      when 6
        @week = "Junio - " + fecha[1].to_s
      when 7
        @week = "Julio - " + fecha[1].to_s
      when 8
        @week = "Agosto - " + fecha[1].to_s
      when 9
        @week = "Setiembre - " + fecha[1].to_s
      when 10
        @week = "Octubre - " + fecha[1].to_s
      when 11
        @week = "Noviembre - " + fecha[1].to_s
      else
        @week = "Diciembre - " + fecha[1].to_s
      end
    else  
      @week = ActiveRecord::Base.connection.execute("
        SELECT CONCAT(name, ': ', DATE_FORMAT(start_date, '%d/%m/%Y'), ' - ', DATE_FORMAT(end_date, '%d/%m/%Y')) 
        FROM  weeks_for_cost_center_"+get_company_cost_center('cost_center').to_s+" 
        WHERE id = " + params[:semana].to_s).first
    end
    @worker = Worker.find(params[:worker])
    @wo = @worker.id
    @concept = Concept.find(params[:concept])
    @co = @concept.id
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

  def complete_select_extra
    extra = Array.new
    if params[:worker] == "empleado"
      fecha = params[:semana].split("-")
      case fecha[0].to_i
      when 1
        @week = "Enero - " + fecha[1].to_s
      when 2
        @week = "Febrero - " + fecha[1].to_s
      when 3
        @week = "Marzo - " + fecha[1].to_s
      when 4
        @week = "Abril - " + fecha[1].to_s
      when 5
        @week = "Mayo - " + fecha[1].to_s
      when 6
        @week = "Junio - " + fecha[1].to_s
      when 7
        @week = "Julio - " + fecha[1].to_s
      when 8
        @week = "Agosto - " + fecha[1].to_s
      when 9
        @week = "Setiembre - " + fecha[1].to_s
      when 10
        @week = "Octubre - " + fecha[1].to_s
      when 11
        @week = "Noviembre - " + fecha[1].to_s
      else
        @week = "Diciembre - " + fecha[1].to_s
      end
    else
      semana = ActiveRecord::Base.connection.execute("
        SELECT *
        FROM weeks_for_cost_center_" + get_company_cost_center('cost_center').to_s + " wc
        WHERE wc.id = " + params[:semana].to_s).first
      @week = semana[1].to_s+ ": del "+ semana[2].strftime('%d/%m/%y') + " al " +semana[3].strftime('%d/%m/%y') 
    end
    @reg_n = (Time.now.to_f*1000).to_i
    extra_info = ExtraInformationForPayslip.where("week = '"+@week.to_s+"'")
    extra_info.each do |ei|
      extra << {'worker_id' => ei.worker_id.to_s, 'wo_name' => ei.worker.entity.name.to_s+" "+ei.worker.entity.second_name.to_s+" "+ei.worker.entity.paternal_surname.to_s+" "+ei.worker.entity.maternal_surname.to_s, 'concept_id'=> ei.concept_id.to_s, 'concept_name'=> ei.concept.name.to_s, 'amount'=> ei.amount.to_s, 'reg'=>@reg_n}
      @reg_n+=1
    end
    render json: {:extra => extra} 
  end    

  def generate_payroll
    @pay = Payslip.new
    @cc = CostCenter.find(get_company_cost_center('cost_center'))
    @company_id = get_company_cost_center('company')
    puts 
    ing = Array.new
    des = Array.new
    apor = Array.new
    TypeOfPayslip.find(params[:tipo]).concepts.where("code LIKE '1%' AND type_"+params[:worker].to_s+" = 'Fijo'").each do |tpc|
      ing << tpc.id
    end
    TypeOfPayslip.find(params[:tipo]).concepts.where("code LIKE '2%' AND type_"+params[:worker].to_s+" = 'Fijo'").each do |tpc|
      des << tpc.id
    end
    TypeOfPayslip.find(params[:tipo]).concepts.where("code LIKE '3%' AND type_"+params[:worker].to_s+" = 'Fijo'").each do |tpc|
      apor << tpc.id
    end
    @reg_n = (Time.now.to_f*1000).to_i

    @extra_info = params[:extra]
    @extra_info = @extra_info.split(';')
    i = 0
    @extra_info.each do |ar|
      @extra_info[i] = ar.split(',')
      i+=1
    end
    @partes = Array.new
    @mensaje = "fail"

    if params[:worker] == "empleado"
      fecha = params[:semana].split(',')
      inicio = fecha[0]+"-"+fecha[1]+"-01"
      d = Date.new(fecha[0].to_i,fecha[1].to_i)
      d +=42
      d = (Date.new(d.year, d.month) - 1)
      case d.strftime("%m")
      when 1
        @month = "Enero - " + d.strftime("%Y").to_s
      when 2
        @month = "Febrero - " + d.strftime("%Y").to_s
      when 3
        @month = "Marzo - " + d.strftime("%Y").to_s
      when 4
        @month = "Abril - " + d.strftime("%Y").to_s
      when 5
        @month = "Mayo - " + d.strftime("%Y").to_s
      when 6
        @month = "Junio - " + d.strftime("%Y").to_s
      when 7
        @month = "Julio - " + d.strftime("%Y").to_s
      when 8
        @month = "Agosto - " + d.strftime("%Y").to_s
      when 9
        @month = "Setiembre - " + d.strftime("%Y").to_s
      when 10
        @month = "Octubre - " + d.strftime("%Y").to_s
      when 11
        @month = "Noviembre - " + d.strftime("%Y").to_s
      else
        @month = "Diciembre - " + d.strftime("%Y").to_s
      end
      d = d.strftime('%Y-%m-%d')
      
      @partes = Payslip.generate_payroll_empleados(@company_id, inicio, d, ing, des, apor, @extra_info, params[:ar_wo])
      @mensaje = "empleado"
    elsif params[:worker] == "obrero"
      semana = ActiveRecord::Base.connection.execute("
        SELECT *
        FROM weeks_for_cost_center_" + @cc.id.to_s + " wc
        WHERE wc.id = " + params[:semana].to_s).first

      tipo = params[:tipo]
      @week = semana[1].to_s+ ": del "+ semana[2].strftime('%d/%m/%y') + " al " +semana[3].strftime('%d/%m/%y') 
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
      tareo = WeeklyWorker.where("start_date = '"+semana[2].to_s+"' AND end_date = '"+semana[3].to_s+"' AND state = 'approved'").first
      if !tareo.nil?
        wg = tareo.working_group.gsub(" ", ",")
      else
        wg = 0
      end
      if wg != 0
        @headers = ['DNI', 'Nombre', 'CAT.', 'C.C', 'ULT. DIA. TRABJ.', 'AFP', 'HIJ', 'HORAS', 'DIAS', 'H.E.S', 'H.FRDO', 'H.E.D']
        @partes = Payslip.generate_payroll_workers(@cc.id, semana[0], semana[2], semana[3], wg, ing, des, apor, @headers, @extra_info, params[:ar_wo])
        @mensaje = "obrero"
      end
    end
    render(partial: 'workers', :layout => false)
  end

  def destroy
    pay = Payroll.find(params[:id])
    pay.destroy
    render :json => pay
  end

  def generate_payroll_excel
    @pay = Payslip.where("code = ?",params[:id])
    Spreadsheet.client_encoding = 'UTF-8'

    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet :name => 'Planilla'
    if params[:type] == "month"
      headers = ['DNI', 'Nombre', 'CAT', 'COMP.', 'AFP', 'HIJ', 'DIAS ASISTIDOS', 'DIAS FALTA']
    else
      headers = ['DNI', 'Nombre', 'CAT', 'C.C', 'ULT. DIA. TRABJ.', 'AFP', 'HIJ', 'HORAS', 'DIAS', 'H.E.S', 'H.FRDO', 'H.E.D']
    end
    headers = headers + JSON.parse(@pay.first.ing_and_amounts).to_a.map(&:first).map{ |i| i.gsub('_', ' ').upcase }
    headers = headers + JSON.parse(@pay.first.des_and_amounts).to_a.map(&:first).map{ |i| i.gsub('_', ' ').upcase }
    headers = headers + JSON.parse(@pay.first.aport_and_amounts).to_a.map(&:first).map{ |i| i.gsub('_', ' ').upcase }

    sheet1.row(2).concat headers

    i = 3
    @pay.each do |pars|
      selected = Array.new
      wor = Worker.find(pars.worker_id)
      if params[:type].to_s == "month"
        selected = [wor.entity.dni, wor.entity.name.to_s + " " + wor.entity.second_name.to_s + " " + wor.entity.paternal_surname.to_s + " "+ wor.entity.maternal_surname.to_s, wor.worker_contracts.where("status = 1").first.article.name, Company.find(pars.company_id).short_name.to_s, wor.worker_afps.first.afp.enterprise.to_s, wor.numberofchilds.to_i, pars.days.to_s, 30-pars.days.to_i]
      elsif params[:type].to_s == "week"
        selected = [wor.entity.dni, wor.entity.name.to_s + " " + wor.entity.second_name.to_s + " " + wor.entity.paternal_surname.to_s + " "+ wor.entity.maternal_surname.to_s, wor.worker_contracts.first.article.name, CostCenter.find(pars.cost_center_id).code, pars.last_worked_day.strftime('%d/%m/%y').to_s, wor.worker_afps.first.afp.enterprise.to_s, wor.numberofchilds.to_i, pars.normal_hours.to_s, pars.days.to_s, pars.he_60.to_s, 0, pars.he_100.to_s]
      end
      selected = selected + JSON.parse(pars.ing_and_amounts).to_a.map(&:second).map{ |i| i.gsub('_', ' ').upcase }
      selected = selected + JSON.parse(pars.des_and_amounts).to_a.map(&:second).map{ |i| i.gsub('_', ' ').upcase }
      selected = selected + JSON.parse(pars.aport_and_amounts).to_a.map(&:second).map{ |i| i.gsub('_', ' ').upcase }
      sheet1.row(i).concat selected
      i += 1
    end

    export_file_path = [Rails.root, "public", "payrolls", "planilla_#{ DateTime.now.to_s }.xls"].join("/")
    book.write export_file_path
    send_file export_file_path, :content_type => "application/vnd.ms-excel", :disposition => 'inline'
  end

  private
  def pay_parameters
    params.require(:payslip).permit(
      :worker_id, 
      :cost_center_id, 
      :start_date, 
      :end_date, 
      :days, 
      :normal_hours, 
      :subsidized_day, 
      :subsidized_hour, 
      :last_worked_day, 
      :he_60, 
      :code, 
      :he_100, 
      :ing_and_amounts, 
      :des_and_amounts, 
      :aport_and_amounts, 
      :month)
  end

  private
  def extra_parameters
    params.require(:extra_information_for_payslip).permit(:worker_id, :concept_id, :amount, :week)
  end  
end