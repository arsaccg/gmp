class Production::ScValuationsController < ApplicationController
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
	def index
		@company = get_company_cost_center('company')
    @scvaluation = ScValuation.all
		render layout: false
	end

  def show
    @id = params[:id] 
    @scvaluation=ScValuation.find_by_id(params[:id])
    @valorizacionsinigv = 0
    @amortizaciondeadelanto = 0
    @totalfacturar = 0
    @totalfacigv = 0
    @totalincluidoigv = 0
    @retenciones = 0
    @detraccion = 0
    @fondogarantia1 = 0
    @fondogarantia2 = 0
    @descuentoequipos = 0
    @otrosdescuentos = 0
    @netoapagar = 0
    @code = 0
    @code = @scvaluation.code.to_i - 1
    @code = @code.to_s.rjust(3,'0')
    @valuationgroup = getsc_valuation2(@scvaluation.start_date, @scvaluation.end_date, @scvaluation.name, @code)
    if @valuationgroup.count > 0
      @valuationgroup.each do |workerDetail|
        @valorizacionsinigv = workerDetail[0]
        @amortizaciondeadelanto = workerDetail[1]
        @totalfacturar = workerDetail[2]
        @totalfacigv = workerDetail[3]
        @totalincluidoigv = workerDetail[4]
        @retenciones = workerDetail[5]
        @detraccion = workerDetail[6]
        @fondogarantia1 = workerDetail[7]
        @fondogarantia2 = workerDetail[8]
        @descuentoequipos = workerDetail[9]
        @otrosdescuentos = workerDetail[10]
        @netoapagar = workerDetail[11]
      end
    end
    render layout: false
  end

  def report_pdf
    respond_to do |format|
      format.html
      format.pdf do
        @cc = get_company_cost_center('cost_center')
        @company = Company.find(get_company_cost_center('company'))
        @id = params[:id] 
        @scvaluation=ScValuation.find_by_id(params[:id])
        @valorizacionsinigv = 0
        @amortizaciondeadelanto = 0
        @totalfacturar = 0
        @totalfacigv = 0
        @totalincluidoigv = 0
        @retenciones = 0
        @detraccion = 0
        @fondogarantia1 = 0
        @fondogarantia2 = 0
        @descuentoequipos = 0
        @otrosdescuentos = 0
        @netoapagar = 0
        @code = 0
        @code = @scvaluation.code.to_i - 1
        @code = @code.to_s.rjust(3,'0')
        @valuationgroup = getsc_valuation2(@scvaluation.start_date, @scvaluation.end_date, @scvaluation.name, @code)
        if @valuationgroup.count > 0
          @valuationgroup.each do |workerDetail|
            @valorizacionsinigv = workerDetail[0]
            @amortizaciondeadelanto = workerDetail[1]
            @totalfacturar = workerDetail[2]
            @totalfacigv = workerDetail[3]
            @totalincluidoigv = workerDetail[4]
            @retenciones = workerDetail[5]
            @detraccion = workerDetail[6]
            @fondogarantia1 = workerDetail[7]
            @fondogarantia2 = workerDetail[8]
            @descuentoequipos = workerDetail[9]
            @otrosdescuentos = workerDetail[10]
            @netoapagar = workerDetail[11]
          end
        end
        render :pdf => "resumen_valorizaciones_sc_#{@scvaluation.name}-#{Time.now.strftime('%d-%m-%Y')}", 
               :template => 'production/sc_valuations/report_pdf.pdf.haml',
               :page_size => 'A4'
      end
    end
  end

	def new
    @executors = Subcontract.where("entity_id NOT LIKE 0")
    last=ScValuation.last
    if !last.nil?
      @start = last.start_date
      @end = last.end_date
    end
		render layout: false
	end

	def get_report
    name = Entity.find_by_id(params[:executor]).name
    if Subcontract.find_by_entity_id(params[:executor])!=nil
      if ScValuation.count > 0
        last = ScValuation.where("name LIKE ? ", name).last
        if last!=nil 
          end_date = last.end_date
          if end_date.to_s < params[:start_date]
            @ejecutar="ok"
          end
        else
          @ejecutar="ok"
        end
      else
        @ejecutar="ok"
      end
    else
      @nhsub="no"
    end

    if @ejecutar=="ok"
      @scValuation = ScValuation.new
      @totalprice = 0
      @totalprice2 = 0
      @totalprice3 = 0
      @subadvances = 0
      @valorizacionsinigv = 0
      @amortizaciondeadelanto = 0
      @amortizaciondeadelantoigv = 0
      @initial_amortization_percent = 0
      @totalfacturar = 0
      @totalfacigv = 0
      @totalincluidoigv = 0
      @retenciones = 0
      @detraccion = 0
      @fondogarantia1 = 0
      @fondogarantia2 = 0
      @descuestoequipos = 0
      @descuentomateriales = 0
      @otrosdescuentos = 0
      @netoactualpagar = 0
      @netoapagar = 0
      @accumulated_valorizacionsinigv = 0
      @accumulated_amortizaciondeadelanto = 0
      @accumulated_totalfacturar = 0
      @accumulated_totalfacigv = 0
      @accumulated_totalincluidoigv = 0
      @accumulated_retenciones = 0
      @accumulated_detraccion = 0
      @accumulated_fondogarantia1 = 0
      @accumulated_fondogarantia2 = 0
      @accumulated_descuestoequipos = 0
      @accumulated_descuentomateriales = 0
      @accumulated_netoapagar = 0
      @cad = Array.new
      @cad2 = Array.new
      @company = params[:company_id]
      @numbercode = 1
      @entity= Entity.find_by_id(params[:executor])
      if params[:executor]=="0"
        @working_group = WorkingGroup.all
      end
      if params[:executor]!="0"
        @working_group = WorkingGroup.where("executor_id LIKE ?", params[:executor])
      end
      @subcontract = Subcontract.find_by_entity_id(params[:executor])
      if @subcontract.initial_amortization_percent != nil
        @initial_amortization_percent = @subcontract.initial_amortization_percent
      end
      @start_date = params[:start_date]
      @end_date = params[:end_date]
      if @working_group.present?
        @working_group.each do |wg|
          @cad << wg.id
        end
        @cad = @cad.join(',')
        puts @cad.inspect
      else
        @cad = '0'
      end
      @cc = get_company_cost_center('cost_center')
      @workers_array = business_days_array(@start_date, @end_date, @cad, @cc)
      @workers_array2 = business_days_array2(@start_date, @end_date, @cad, @cc)
      @workers_array3 = business_days_array3(@start_date, @end_date, @cad, @cc)
      @workers_array.each do |workerDetail|
        @totalprice += workerDetail[7].to_f + workerDetail[8].to_f + workerDetail[9].to_f
      end
      @workers_array2.each do |workerDetail|
        @totalprice2 += workerDetail[3]*workerDetail[4]
      end
      @workers_array3.each do |workerDetail|
        @totalprice3 += workerDetail[4]
      end
      @subcontract.subcontract_advances.each do |subadvances|
        @subadvances+=subadvances.advance
      end
      if @subcontract.initial_amortization_number.to_f>@subadvances || @subcontract.initial_amortization_percent.to_f>@subadvances
        @subcontract.initial_amortization_number=0
        @subcontract.initial_amortization_percent=0
      end
      @totalbill= @totalprice2.to_f-@subcontract.initial_amortization_number.to_f
      @totalbilligv= (@totalprice2-@subcontract.initial_amortization_number.to_f)*@subcontract.igv
      @totalbillwigv= @totalbill+@totalbilligv
      @retention=@subcontract.detraction.to_i+@subcontract.guarantee_fund.to_i+@totalprice+@totalprice3
      @valuationgroup = getsc_valuation(@start_date, @end_date, @entity.name)
      if @valuationgroup.count > 0
        @valuationgroup.each do |workerDetail|
          @valorizacionsinigv = workerDetail[0]
          @amortizaciondeadelanto = workerDetail[1]
          @totalfacturar = workerDetail[2]
          @totalfacigv = workerDetail[3]
          @totalincluidoigv = workerDetail[4]
          @retenciones = workerDetail[5]
          @detraccion = workerDetail[6]
          @fondogarantia1 = workerDetail[7]
          @fondogarantia2 = workerDetail[8]
          @descuestoequipos = workerDetail[9]
          @otrosdescuentos = workerDetail[10]
          @netoapagar = workerDetail[11]
          @numbercode = workerDetail[12]
        end
        @numbercode=@numbercode.to_i
        @numbercode += 1
      end
      @numbercode = @numbercode.to_s.rjust(3,'0')
      @accumulated_valorizacionsinigv = @totalprice2+@valorizacionsinigv
      @accumulated_amortizaciondeadelanto = @subcontract.initial_amortization_number.to_f+@amortizaciondeadelanto
      @accumulated_totalfacturar = @totalbill+@totalfacturar
      @accumulated_totalfacigv = @totalbilligv+@totalfacigv
      @accumulated_totalincluidoigv = @totalbillwigv+@totalincluidoigv
      @accumulated_retenciones = @retention+@retenciones
      @accumulated_detraccion = @subcontract.detraction.to_f+@retenciones
      @accumulated_fondogarantia1 = @subcontract.guarantee_fund.to_f+@fondogarantia1
      @accumulated_fondogarantia2 = @totalprice+@fondogarantia2
      @accumulated_descuestoequipos = @totalprice3+@descuestoequipos
      @accumulated_descuentomateriales = @descuentomateriales
      @netoactualpagar=@totalbillwigv-@retention
      @accumulated_netoapagar = @accumulated_totalincluidoigv-@accumulated_retenciones
      @balance = @subadvances - @accumulated_amortizaciondeadelanto    
      @flag="ok"
    else
      @flag="no"
    end
    @cc = get_company_cost_center('cost_center')
    @inicio = ActiveRecord::Base.connection.execute("SELECT name FROM weeks_for_cost_center_"+get_company_cost_center('cost_center').to_s+" WHERE start_date <= '"+@start_date+"' AND end_date >= '"+@start_date.to_s+"'").first
    @fin = ActiveRecord::Base.connection.execute("SELECT name FROM weeks_for_cost_center_"+get_company_cost_center('cost_center').to_s+" WHERE start_date <= '"+@end_date+"' AND end_date >= '"+@end_date.to_s+"'").first

    render(partial: 'report_table', :layout => false)
  end

  def business_days_array(start_date, end_date, working_group_id,cost_center)
    workers_array = ActiveRecord::Base.connection.execute("
      SELECT  art.name AS category,
        cow.normal_price,
        cow.he_60_price,
        cow.he_100_price,
        SUM( ppd.normal_hours ) AS normal_hours, 
        SUM( ppd.he_60 ) AS he_60, 
        SUM( ppd.he_100 ) AS he_100, 
        cow.normal_price*SUM( ppd.normal_hours ), 
        cow.he_60_price*SUM( ppd.he_60 ), 
        cow.he_100_price*SUM( ppd.he_100 ),
        uom.name, 
        p.date_of_creation 
      FROM part_people p, unit_of_measurements uom, part_person_details ppd, workers w, category_of_workers cow, articles art, worker_contracts wc 
      WHERE p.working_group_id IN(" + working_group_id.to_s + ")
      AND p.date_of_creation BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND p.id = ppd.part_person_id
      AND p.cost_center_id = '" + cost_center.to_s + "'
      AND w.cost_center_id = '" + cost_center.to_s + "'
      AND w.id = wc.worker_id
      AND wc.status = 1
      AND wc.article_id = art.id
      AND ppd.worker_id = w.id
      AND p.block=0 
      AND wc.article_id = cow.article_id
      AND uom.id = art.unit_of_measurement_id
      GROUP BY art.name
    ")
    return workers_array
  end

  def business_days_array2(start_date, end_date, working_group_id, cost_center)
    workers_array2 = ActiveRecord::Base.connection.execute("
      SELECT 
        pwd.itembybudget_id, 
        ibb.subbudgetdetail, 
        ibb.order, 
        SUM(pwd.bill_of_quantitties) as bill_of_quantitties,
        ibb.price as price,
        ibb.budget_id as budget_id,
        p.date_of_creation 
      FROM part_works p, part_work_details pwd, itembybudgets ibb
      WHERE p.date_of_creation BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND p.working_group_id IN(" + working_group_id.to_s + ")
      AND p.cost_center_id = '" + cost_center.to_s + "'
      AND p.id = pwd.part_work_id
      AND p.block=0 
      AND pwd.itembybudget_id =  ibb.id
      GROUP BY ibb.subbudgetdetail
    ")
    return workers_array2
  end

  def business_days_array3(start_date, end_date, working_group_id, cost_center)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT  art.name, 
      uom.name, 
      SUM( poed.effective_hours ), 
      si.price_no_igv, 
      si.price_no_igv*SUM( poed.effective_hours) 
      FROM part_of_equipments poe, part_of_equipment_details poed, articles art, unit_of_measurements uom, subcontract_equipment_details si
      WHERE poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND poe.id=poed.part_of_equipment_id
      AND poe.equipment_id=art.id
      AND poe.cost_center_id = '" + cost_center.to_s + "'
      AND poe.equipment_id=si.article_id
      AND poe.block=0 
      AND uom.id = art.unit_of_measurement_id
      AND poed.working_group_id IN(" + working_group_id.to_s + ")
      GROUP BY art.name
    ")
    return workers_array3
  end

  def getsc_valuation(start_date, end_date, entityname)
    valuationgroup = ActiveRecord::Base.connection.execute("
      SELECT accumulated_valuation, 
      accumulated_initial_amortization_number, 
      accumulated_bill, accumulated_billigv, 
      accumulated_totalbill, 
      accumulated_retention, 
      accumulated_detraction, 
      accumulated_guarantee_fund1, 
      accumulated_guarantee_fund2, 
      accumulated_equipment_discount, 
      accumulated_otherdiscount, 
      accumulated_net_payment, 
      code 
      FROM sc_valuations 
      WHERE name LIKE '" + entityname + "'
      ORDER BY id DESC LIMIT 1
    ")
    return valuationgroup
  end

  def getsc_valuation2(start_date, end_date, entityname, code)
    valuationgroup = ActiveRecord::Base.connection.execute("
      SELECT accumulated_valuation, 
      accumulated_initial_amortization_number, 
      accumulated_bill, accumulated_billigv, 
      accumulated_totalbill, 
      accumulated_retention, 
      accumulated_detraction, 
      accumulated_guarantee_fund1, 
      accumulated_guarantee_fund2, 
      accumulated_equipment_discount, 
      accumulated_otherdiscount, 
      accumulated_net_payment, 
      code 
      FROM sc_valuations 
      WHERE name LIKE '" + entityname + "'
      AND code LIKE '" + code + "'
    ")
    return valuationgroup
  end

  def updateParts(start_date, end_date)
    ActiveRecord::Base.connection.execute("
      Update part_works set block = 1 where date_of_creation BETWEEN '" + start_date + "' AND '" + end_date + "'
    ")
    ActiveRecord::Base.connection.execute("
      Update part_people set block = 1 where date_of_creation BETWEEN '" + start_date + "' AND '" + end_date + "'
    ")
    ActiveRecord::Base.connection.execute("
      Update part_of_equipments set block = 1 where date BETWEEN '" + start_date + "' AND '" + end_date + "'
    ")
  end

  def create
    scvaluation = ScValuation.new(sc_valuation_parameters)
    scvaluation.state
    scvaluation.cost_center_id = get_company_cost_center('cost_center')
    if scvaluation.save
      redirect_to :action => :index, company_id: params[:company_id]
    else
      scvaluation.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def destroy
    scvaluation = ScValuation.destroy(params[:id])
    render :json => scvaluation
  end

  def part_work
    if !params[:id].nil?
      @id = params[:id]
      scvaluation = ScValuation.find_by_id(@id)
      entity = Entity.find_by_name(scvaluation.name)
      @subcontract = Subcontract.find_by_entity_id(entity.id)
    end
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @cad = params[:cad]
    @totalprice2 = 0
    cc = get_company_cost_center("cost_center")
    @workers_array2 = business_days_array2(@start_date, @end_date, @cad,cc)
    @workers_array2.each do |workerDetail|
      @totalprice2 += workerDetail[5]
    end
    render layout: false
  end

  def part_work_pdf
    respond_to do |format|
      format.html
      format.pdf do
          @scvaluation=ScValuation.find_by_id(params[:id])
        if !@scvaluation.nil?
          entity = Entity.find_by_name(@scvaluation.name)
          puts entity.name
          @subcontract = Subcontract.find_by_entity_id(entity.id)
        end
        start_date = params[:start_date]
        end_date = params[:end_date]
        cad = params[:cad]
        @cc = get_company_cost_center('cost_center')
        @company = Company.find(get_company_cost_center('company'))
        @totalprice2 = 0
        cc = get_company_cost_center("cost_center")
        @workers_array2 = business_days_array2(start_date, end_date, cad,@cc)
        @workers_array2.each do |workerDetail|
          @totalprice2 += workerDetail[5]
        end
        render :pdf => "parte_obra_#{Time.now.strftime('%d-%m-%Y')}", 
               :template => 'production/sc_valuations/part_work_pdf.pdf.haml',
               :page_size => 'A4'
      end
    end
  end

  def part_people
    start_date = params[:start_date]
    end_date = params[:end_date]
    cad = params[:cad]
    cost_center = get_company_cost_center('cost_center')
    @totalprice = 0
    @workers_array = business_days_array(start_date, end_date, cad,cost_center)
    @workers_array.each do |workerDetail|
      @totalprice += workerDetail[7] + workerDetail[8] + workerDetail[9]
    end
    render layout: false
  end

  def part_equipment
    start_date = params[:start_date]
    end_date = params[:end_date]
    cost_center = get_company_cost_center('cost_center')
    cad = params[:cad]
    @totalprice3 = 0
    @workers_array3 = business_days_array3(start_date, end_date, cad,cost_center)
    @workers_array3.each do |workerDetail|
      @totalprice3 += workerDetail[4]
    end
    render layout: false
  end

  def approve
    start_date = params[:start_date]
    end_date = params[:end_date]
    updateParts(start_date,end_date)
    scvaluation = ScValuation.find(params[:id])
    scvaluation.approve
    redirect_to :action => :index
  end

  private
  def sc_valuation_parameters
    params.require(:sv_valuation).permit(:name, :start_date, :end_date, :working_group, :valuation, :initial_amortization_number, :initial_amortization_percentage, :bill, :billigv, :totalbill , :retention , :detraction , :guarantee_fund1 , :guarantee_fund2 , :equipment_discount , :material_discount , :hired_amount , :advances , :accumulated_amortization , :balance , :net_payment , :accumulated_valuation , :accumulated_initial_amortization_number , :accumulated_bill , :accumulated_billigv , :accumulated_totalbill , :accumulated_retention , :accumulated_detraction , :accumulated_guarantee_fund1 , :accumulated_guarantee_fund2 , :accumulated_equipment_discount , :accumulated_net_payment , :code, :otherdiscount, :accumulated_otherdiscount)
  end
end
