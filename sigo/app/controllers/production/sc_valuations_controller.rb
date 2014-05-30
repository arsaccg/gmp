class Production::ScValuationsController < ApplicationController
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
	def index
		@company = get_company_cost_center('company')
    @scvaluation = ScValuation.all
		render layout: false
	end

  def show
    render layout: false
  end

	def new		
		TypeEntity.where("name LIKE '%Proveedores%'").each do |executor|
      @executors = executor.entities
    end
    last=ScValuation.last
    if !last.nil?
      @start = last.start_date
      @end = last.end_date
    end
		render layout: false
	end

	def get_report
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
    else
      @cad = '0'
    end
    @workers_array = business_days_array(@start_date, @end_date, @cad)
    @workers_array2 = business_days_array2(@start_date, @end_date, @cad)
    @workers_array3 = business_days_array3(@start_date, @end_date, @cad)
    @workers_array.each do |workerDetail|
      @totalprice += workerDetail[7] + workerDetail[8] + workerDetail[9]
    end
    @workers_array2.each do |workerDetail|
      @totalprice2 += workerDetail[5]
    end
    @workers_array3.each do |workerDetail|
      @totalprice3 += workerDetail[4]
    end
    @subcontract.subcontract_advances.each do |subadvances|
      @subadvances+=subadvances.advance
    end
    @totalbill= @totalprice2-@subcontract.initial_amortization_number
    @totalbilligv= (@totalprice2-@subcontract.initial_amortization_number)*@subcontract.igv
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
        @netoapagar = workerDetail[10]
        @numbercode = workerDetail[11]
      end
      @numbercode=@numbercode.to_i
      @numbercode += 1
    end
    @numbercode = @numbercode.to_s.rjust(3,'0')
    @accumulated_valorizacionsinigv = @totalprice2+@valorizacionsinigv
    @accumulated_amortizaciondeadelanto = @subcontract.initial_amortization_number+@amortizaciondeadelantoigv
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
    @balance = @subadvances + @accumulated_amortizaciondeadelanto
    render(partial: 'report_table', :layout => false)
  end

  def business_days_array(start_date, end_date, working_group_id)
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
      FROM part_people p, unit_of_measurements uom, part_person_details ppd, workers w, category_of_workers cow, articles art
      WHERE p.working_group_id IN(" + working_group_id + ")
      AND p.date_of_creation BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND p.id = ppd.part_person_id
      AND w.article_id = art.id
      AND ppd.worker_id = w.id
      AND w.article_id = cow.article_id
      AND uom.id = art.unit_of_measurement_id
      GROUP BY art.name
    ")
    return workers_array
  end

  def business_days_array2(start_date, end_date, working_group_id)
    workers_array2 = ActiveRecord::Base.connection.execute("
      SELECT  pwd.article_id, 
        art.name, 
        uom.name, 
        SUM( pwd.bill_of_quantitties ), 
        si.price, 
        si.price*SUM( pwd.bill_of_quantitties ), 
        p.date_of_creation 
      FROM part_works p, part_work_details pwd, articles art, unit_of_measurements uom, subcontract_inputs si
      WHERE p.date_of_creation BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND p.working_group_id IN(" + working_group_id + ")
      AND p.id = pwd.part_work_id
      AND pwd.article_id = art.id
      AND pwd.article_id = si.article_id
      AND uom.id = art.unit_of_measurement_id
      GROUP BY art.name
    ")
    return workers_array2
  end

  def business_days_array3(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT  art.name, 
      uom.name, 
      SUM( poed.effective_hours ), 
      si.price, 
      si.price*SUM( poed.effective_hours) 
      FROM part_of_equipments poe, part_of_equipment_details poed, articles art, unit_of_measurements uom, subcontract_inputs si
      WHERE poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND poe.id=poed.part_of_equipment_id
      AND poe.equipment_id=art.id
      AND poe.equipment_id=si.article_id
      AND uom.id = art.unit_of_measurement_id
      AND poed.working_group_id IN(" + working_group_id + ")
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
      accumulated_net_payment, 
      code 
      FROM sc_valuations 
      WHERE name LIKE '" + entityname + "'
      ORDER BY id DESC LIMIT 1
    ")
    return valuationgroup
  end

  def create
    scvaluation = ScValuation.new(sc_valuation_parameters)
    scvaluation.state
    if scvaluation.save
      flash[:notice] = "Se ha creado correctamente la valorizacion."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      scvaluation.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def destroy
    scvaluation = ScValuation.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el trabajador."
    render :json => scvaluation
  end

  def part_work
    start_date = params[:start_date]
    end_date = params[:end_date]
    cad = params[:cad]
    @totalprice2 = 0
    @workers_array2 = business_days_array2(start_date, end_date, cad)
    @workers_array2.each do |workerDetail|
      @totalprice2 += workerDetail[5]
    end
    render layout: false
  end
  def part_people
    start_date = params[:start_date]
    end_date = params[:end_date]
    cad = params[:cad]
    @totalprice = 0
    @workers_array = business_days_array(start_date, end_date, cad)
    @workers_array.each do |workerDetail|
      @totalprice += workerDetail[7] + workerDetail[8] + workerDetail[9]
    end
    render layout: false
  end
  def part_equipment
    start_date = params[:start_date]
    end_date = params[:end_date]
    cad = params[:cad]
    @totalprice3 = 0
    @workers_array3 = business_days_array3(start_date, end_date, cad)
    @workers_array3.each do |workerDetail|
      @totalprice3 += workerDetail[4]
    end
    render layout: false
  end

  private
  def sc_valuation_parameters
    params.require(:sv_valuation).permit(:name, :start_date, :end_date, :working_group, :valuation, :initial_amortization_number, :initial_amortization_percentage, :bill, :billigv, :totalbill , :retention , :detraction , :guarantee_fund1 , :guarantee_fund2 , :equipment_discount , :material_discount , :hired_amount , :advances , :accumulated_amortization , :balance , :net_payment , :accumulated_valuation , :accumulated_initial_amortization_number , :accumulated_bill , :accumulated_billigv , :accumulated_totalbill , :accumulated_retention , :accumulated_detraction , :accumulated_guarantee_fund1 , :accumulated_guarantee_fund2 , :accumulated_equipment_discount , :accumulated_net_payment , :code, :otherdiscount, :accumulated_otherdiscount)
  end
end
