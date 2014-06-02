class Production::ValuationOfEquipmentsController < ApplicationController
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
	def index
		@company = get_company_cost_center('company')
  	@valuationofequipment = ValuationOfEquipment.all
    @subcontractequipmentdetail = SubcontractEquipmentDetail.all
    render layout: false
	end
    
  def show
    @valuationofequipment=ValuationOfEquipment.find_by_id(params[:id])
    @valorizacionsinigv = 0
    @amortizaciondeadelanto = 0
    @totalfacturar = 0
    @totalfacigv = 0
    @totalincluidoigv = 0
    @retenciones = 0
    @detraccion = 0
    @descuentocombustible = 0
    @otrosdescuentos = 0
    @netoapagar = 0
    @code = 0
    @code = @valuationofequipment.code.to_i - 1
    @code = @code.to_s.rjust(3,'0')
    @valuationofequipment2 = getsc_valuation2(@valuationofequipment.start_date, @valuationofequipment.end_date, @valuationofequipment.name, @code)
    if @valuationofequipment2.count > 0
      @valuationofequipment2.each do |workerDetail|
        @valorizacionsinigv = workerDetail[0]
        @amortizaciondeadelanto = workerDetail[1]
        @totalfacturar = workerDetail[2]
        @totalfacigv = workerDetail[3]
        @totalincluidoigv = workerDetail[4]
        @retenciones = workerDetail[5]
        @detraccion = workerDetail[6]
        @descuentocombustible = workerDetail[7]
        @otrosdescuentos = workerDetail[8]
        @netoapagar = workerDetail[9]
      end
    end
    render layout: false
  end
	def new
		@costCenter = CostCenter.new
		TypeEntity.where("name LIKE '%Proveedores%'").each do |executor|
	      @executors = executor.entities
	    end
    last=ValuationOfEquipment.last
    if !last.nil?
      @start = last.start_date
      @end = last.end_date
    end
		render layout: false
	end

	def get_report
    name = Entity.find_by_id(params[:executor]).name
    if ValuationOfEquipment.count > 0
      last = ValuationOfEquipment.where("name LIKE ? ", name).last
      end_date = last.end_date
      if end_date.to_s < params[:start_date]
        @valuationofequipment = ValuationOfEquipment.new
        @cad = Array.new
        @start_date = params[:start_date]
        @end_date = params[:end_date]
        @subcontractequipment = SubcontractEquipment.find_by_entity_id(params[:executor])
        @working_group = WorkingGroup.where("executor_id LIKE ?", params[:executor])
        @numbercode = 1
        @subadvances = 0
        @fuel_discount = 0
        @initial_amortization_percent = 0
        @accumulated_amortizaciondeadelanto = 0
        @totalprice = 0
        @bill = 0
        @valorizacionsinigv = 0
        @amortizaciondeadelanto = 0
        @totalfacturar = 0
        @totalfacigv = 0
        @totalincluidoigv = 0
        @detracciontotal = 0
        @descuentocombustible = 0
        @descuentootros = 0
        @totalretenciones = 0
        @netoapagar = 0
        @subcontractequipment.subcontract_equipment_advances.each do |subadvances|
          @subadvances+=subadvances.advance
        end
        if @subcontractequipment.initial_amortization_percent != nil
          @initial_amortization_percent = @subcontractequipment.initial_amortization_percent
        end
        if @working_group.present?
          @working_group.each do |wg|
            @cad << wg.id
          end
          @cad = @cad.join(',')
        else
          @cad = '0'
        end
        @valuationgroup = getsc_valuation(@start_date, @end_date, @subcontractequipment.entity.name)
        if @valuationgroup.count > 0
          @valuationgroup.each do |workerDetail|
            @valorizacionsinigv = workerDetail[0]
            @amortizaciondeadelanto = workerDetail[1]
            @totalfacturar = workerDetail[2]
            @totalfacigv = workerDetail[3]
            @totalincluidoigv = workerDetail[4]
            @retenciones = workerDetail[5]
            @detraccion = workerDetail[6]
            @descuesto = workerDetail[7]
            @descuentocombustible = workerDetail[8]
            @netoapagar = workerDetail[9]
            @numbercode = workerDetail[10]
          end
          @numbercode=@numbercode.to_i
          @numbercode += 1
        end
        @workers_array3 = business_days_array3(@start_date, @end_date, @cad)
        @workers_array3.each do |workerDetail|
          @totalprice += workerDetail[4]
        end
        @balance = @subadvances + @accumulated_amortizaciondeadelanto
        @bill = @totalprice-@subcontractequipment.initial_amortization_number
        @billigv = @bill*0.18
        @numbercode = @numbercode.to_s.rjust(3,'0')
        @flag = "ok"
      else
        @flag= "no"
      end
    else
      @valuationofequipment = ValuationOfEquipment.new
      @cad = Array.new
      @start_date = params[:start_date]
      @end_date = params[:end_date]
      @subcontractequipment = SubcontractEquipment.find_by_entity_id(params[:executor])
      @working_group = WorkingGroup.where("executor_id LIKE ?", params[:executor])
      @numbercode = 1
      @subadvances = 0
      @fuel_discount = 0
      @initial_amortization_percent = 0
      @accumulated_amortizaciondeadelanto = 0
      @totalprice = 0
      @bill = 0
      @valorizacionsinigv = 0
      @amortizaciondeadelanto = 0
      @totalfacturar = 0
      @totalfacigv = 0
      @totalincluidoigv = 0
      @detracciontotal = 0
      @descuentocombustible = 0
      @descuentootros = 0
      @totalretenciones = 0
      @netoapagar = 0
      @subcontractequipment.subcontract_equipment_advances.each do |subadvances|
        @subadvances+=subadvances.advance
      end
      if @subcontractequipment.initial_amortization_percent != nil
        @initial_amortization_percent = @subcontractequipment.initial_amortization_percent
      end
      if @working_group.present?
        @working_group.each do |wg|
          @cad << wg.id
        end
        @cad = @cad.join(',')
      else
        @cad = '0'
      end
      @workers_array3 = business_days_array3(@start_date, @end_date, @cad)
      @workers_array3.each do |workerDetail|
        @totalprice += workerDetail[4]
      end
      @balance = @subadvances + @accumulated_amortizaciondeadelanto
      @bill = @totalprice-@subcontractequipment.initial_amortization_number
      @billigv = @bill*0.18
      @numbercode = @numbercode.to_s.rjust(3,'0')
      @flag = "ok"
    end
    
    
    
    render(partial: 'report_table', :layout => false)
  end

  def business_days_array3(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT  art.name, 
      uom.name, 
      SUM( poed.effective_hours ), 
      si.price, 
      si.price*SUM( poed.effective_hours), 
      sed.code, 
      art.id 
      FROM part_of_equipments poe, part_of_equipment_details poed, articles art, unit_of_measurements uom, subcontract_inputs si, subcontract_equipment_details sed
      WHERE poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND poe.id=poed.part_of_equipment_id
      AND poe.equipment_id=art.id
      AND poe.equipment_id=si.article_id
      AND uom.id = art.unit_of_measurement_id
      AND poe.subcontract_equipment_id = sed.subcontract_equipment_id
      AND art.id = sed.article_id
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
      accumulated_fuel_discount, 
      accumulated_other_discount, 
      accumulated_net_payment, 
      code 
      FROM valuation_of_equipments
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
      accumulated_fuel_discount, 
      accumulated_other_discount, 
      accumulated_net_payment, 
      code 
      FROM valuation_of_equipments 
      WHERE name LIKE '" + entityname + "' 
      AND code LIKE '" + code + "'
    ")
    return valuationgroup
  end

  def create
    valuationofequipment = ValuationOfEquipment.new(valuation_of_equipment_parameters)
    valuationofequipment.state
    if valuationofequipment.save
      flash[:notice] = "Se ha creado correctamente la valorizacion."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      valuationofequipment.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def destroy
    valuationofequipment = ValuationOfEquipment.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el trabajador."
    render :json => valuationofequipment
  end

  def part_equipment
    @name = params[:name]
    @code = params[:code]
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @cad = params[:cad]
    @totalprice3 = 0
    @workers_array3 = business_days_array3(@start_date, @end_date, @cad)
    @workers_array3.each do |workerDetail|
      @totalprice3 += workerDetail[4]
    end
    render layout: false
  end

  def report_of_equipment
    @totaldif = 0
    @totaltotalhours = 0
    @totalfuel_amount = 0
    @subcontractequipmentarticle= params[:subcontractequipment]
    start_date = params[:start_date]
    end_date = params[:end_date]
    @poe_array = poe_array(start_date, end_date, @subcontractequipmentarticle)
    @poe_array.each do |workerDetail|
      @totaldif += workerDetail[4].to_i
      @totaltotalhours += workerDetail[5]
      @totalfuel_amount += workerDetail[7]
    end
    @dias_habiles =  range_business_days(start_date,end_date)
    render layout: false
  end

  def range_business_days(start_date, end_date)
    start_date_var = start_date.to_date
    end_date_var = end_date.to_date
    business_days = []
    while end_date_var >= start_date_var
      business_days << start_date_var
      start_date_var = start_date_var + 1.day
    end
    return business_days
  end
  
  def poe_array(start_date, end_date, working_group_id)
    poe_array = ActiveRecord::Base.connection.execute("
      SELECT poe.code, poe.date, poe.initial_km, poe.final_km, poe.dif, poe.total_hours, art.name, poe.fuel_amount
      FROM part_of_equipments poe, articles art, subcontract_equipments sce
      WHERE poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND sce.id=poe.subcontract_equipment_id
      AND poe.subcategory_id=art.id
      AND poe.equipment_id IN(" + working_group_id + ")
      ORDER BY poe.date
    ")
    return poe_array
  end

  def approve
    valuationOfEquipment = ValuationOfEquipment.find(params[:id])
    valuationOfEquipment.approve
    redirect_to :action => :index
  end

  private
  def valuation_of_equipment_parameters
    params.require(:valuation_of_equipment).permit(:name , :code , :start_date , :end_date , :working_group , :valuation , :initial_amortization_number , :initial_amortization_percentage , :bill , :billigv , :totalbill , :retention , :detraction , :fuel_discount , :othvaluation_of_equipmenter_discount , :hired_amount , :advances , :accumulated_amortization , :balance , :net_payment , :accumulated_valuation , :accumulated_initial_amortization_number , :accumulated_bill , :accumulated_billigv , :accumulated_totalbill , :accumulated_retention , :accumulated_detraction , :accumulated_fuel_discount , :accumulated_other_discount , :accumulated_net_payment)
  end
end