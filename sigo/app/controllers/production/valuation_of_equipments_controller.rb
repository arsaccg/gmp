class Production::ValuationOfEquipmentsController < ApplicationController
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @company = get_company_cost_center('company')
    #@valuationofequipment = ValuationOfEquipment.all
    @subcontractEquipments = SubcontractEquipment.where("cost_center_id = "+ get_company_cost_center('cost_center').to_s)
    #@subcontractequipmentdetail = SubcontractEquipmentDetail.all
    render layout: false
  end
    
  def show
    @action = "show"
    @valuationofequipment=ValuationOfEquipment.find_by_id(params[:id])
    @detraccion = @valuationofequipment.detraction
    @start_date = @valuationofequipment.start_date
    @end_date = @valuationofequipment.end_date
    @ids=params[:id]
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
        @descuentocombustible = workerDetail[7]
        @otrosdescuentos = workerDetail[8]
        @netoapagar = workerDetail[9]
      end
    end
    @cc = get_company_cost_center('cost_center')
    @inicio = ActiveRecord::Base.connection.execute("SELECT name FROM weeks_for_cost_center_"+get_company_cost_center('cost_center').to_s+" WHERE start_date <= '"+@start_date.to_s+"' AND end_date >= '"+@start_date.to_s+"'").first
    @fin = ActiveRecord::Base.connection.execute("SELECT name FROM weeks_for_cost_center_"+get_company_cost_center('cost_center').to_s+" WHERE start_date <= '"+@end_date.to_s+"' AND end_date >= '"+@end_date.to_s+"'").first
    render layout: false
  end

  def new
    @action="new"
    @costCenter = CostCenter.new
    @executors = SubcontractEquipment.all
    last=ValuationOfEquipment.last
    if !last.nil?
      @start = last.start_date
      @end = last.end_date
    end
    render layout: false
  end

  def get_report
    @action= "report"
    @name = Entity.find_by_id(params[:executor]).name
    @subcontract_equipment_id = params[:subcontract]
    if SubcontractEquipment.find(@subcontract_equipment_id)!=nil
      if ValuationOfEquipment.count > 0
        last = ValuationOfEquipment.where("name LIKE ? AND subcontract_equipment_id = "+@subcontract_equipment_id.to_s, @name).last
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

    if @ejecutar == "ok"
      @valuationofequipment = ValuationOfEquipment.new
      @cad = Array.new
      @start_date = params[:start_date]
      @end_date = params[:end_date]
      @subcontractequipment = SubcontractEquipment.find_by_entity_id(params[:executor])
      @cad = @subcontractequipment.id
      @lastvaluation = ValuationOfEquipment.find(:last,:conditions => [ "subcontract_equipment_id = ?", @subcontractequipment.id])
      if !@lastvaluation.nil?
        @numbercode = @lastvaluation.code.to_i+1
      else
        @numbercode = 1
      end
      @detraccion = @subcontractequipment.detraction
      @subadvances = 0
      @fuel_discount = 0
      @initial_amortization_percent = 0
      @accumulated_amortizaciondeadelanto = 0
      @totalprice = 0
      @bill = 0
      @totalbill = 0
      @valorizacionsinigv = 0
      @amortizaciondeadelanto = 0
      @totalfacturar = 0
      @totalfacigv = 0
      @totalincluidoigv = 0
      @detracciontotal = 0
      @descuentocombustible = 0
      @descuentootros = 0
      @accumulated_detraction = 0
      @accumulated_descuentootros = 0
      @totalretenciones = 0
      @netoapagar = 0
      @code = 0
      @detraction1 =0
      if !@lastvaluation.nil?
        @code = @lastvaluation.code.to_i      
        @code = @code.to_s.rjust(3,'0')
        @valuationofequipment2 = getsc_valuation2(@valuationofequipment.start_date, @valuationofequipment.end_date, Entity.find(params[:executor]).name, @code)
        if @valuationofequipment2.count > 0
          @valuationofequipment2.each do |workerDetail|
            @valorizacionsinigv = workerDetail[0]
            @amortizaciondeadelanto = workerDetail[1]
            @totalfacturar = workerDetail[2]
            @totalfacigv = workerDetail[3]
            @totalincluidoigv = workerDetail[4]
            @retenciones = workerDetail[5]
            @descuentocombustible = workerDetail[7]
            @otrosdescuentos = workerDetail[8]
            @netoapagar = workerDetail[9]
            @descuentootros = workerDetail[11]
            @accumulated_detraction = workerDetail[6]
            @totalbill = workerDetail[13]
            @detraction1 = workerDetail[14]
            puts @valorizacionsinigv
            puts @amortizaciondeadelanto
            puts @totalfacturar
            puts @totalfacigv
            puts @totalincluidoigv
            puts @retenciones
            puts @detraccion
            puts @descuentocombustible
            puts @otrosdescuentos
            puts @netoapagar
            puts @descuentootros

          end
        end
      end
      @subcontractequipment.subcontract_equipment_advances.each do |subadvances|
        @subadvances+=subadvances.advance
      end
      if @subcontractequipment.initial_amortization_percent != nil
        @initial_amortization_percent = @subcontractequipment.initial_amortization_percent
      end
      @cc = get_company_cost_center('cost_center')
      @workers_array3 = business_days_array3(@start_date, @end_date, @cad, @cc)
      @workers_array3.each do |workerDetail|
        @totalprice += workerDetail[4]
      end
      @balance = @subadvances + @accumulated_amortizaciondeadelanto
      @bill = @totalprice-@subcontractequipment.initial_amortization_number.to_f
      @billigv = @bill*0.18
      @numbercode = @numbercode.to_s.rjust(3,'0')
      @flag = "ok"

    else
      @flag="no"
    end
    render(partial: 'report_table', :layout => false)
  end

  def business_days_array3(start_date, end_date, working_group_id, cost_center)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT poe.equipment_id, sed.code, SUM(poed.effective_hours), sed.price_no_igv, SUM(poed.effective_hours)*sed.price_no_igv
      FROM part_of_equipments poe, part_of_equipment_details poed, subcontract_equipment_details sed
      WHERE poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND poe.id=poed.part_of_equipment_id
      AND poe.cost_center_id = '" + cost_center.to_s + "'
      AND poe.equipment_id=sed.id
      AND poe.subcontract_equipment_id = " + working_group_id.to_s + "
      GROUP BY poe.equipment_id
    ")
    return workers_array3
  end

  def business_days_array6(start_date, end_date, working_group_id, cost_center)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT poe.equipment_id, SUM(poed.effective_hours)
      FROM part_of_equipments poe, part_of_equipment_details poed, subcontract_equipment_details sed
      WHERE poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND poe.id=poed.part_of_equipment_id
      AND poe.cost_center_id = '" + cost_center.to_s + "'
      AND poe.equipment_id=sed.id
      AND poe.subcontract_equipment_id = " + working_group_id.to_s + "
      GROUP BY poe.equipment_id
    ")
    return workers_array3
  end

  def business_days_array5(end_date, working_group_id, cost_center)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT poe.equipment_id, sed.code, SUM(poed.effective_hours), sed.price_no_igv, SUM(poed.effective_hours)*sed.price_no_igv
      FROM part_of_equipments poe, part_of_equipment_details poed, subcontract_equipment_details sed
      WHERE poe.date <= '" + end_date + "'
      AND poe.id=poed.part_of_equipment_id
      AND poe.cost_center_id = '" + cost_center.to_s + "'
      AND poe.equipment_id=sed.id
      AND poe.subcontract_equipment_id = " + working_group_id.to_s + "
      GROUP BY poe.equipment_id
    ")
    return workers_array3
  end

  def last(start_date,end_date, working_group_id, article, cost_center)
    last = ActiveRecord::Base.connection.execute("
      SELECT poe.equipment_id, sed.code, SUM(poed.effective_hours), sed.price_no_igv, SUM(poed.effective_hours)*sed.price_no_igv
      FROM part_of_equipments poe, part_of_equipment_details poed, subcontract_equipment_details sed
      WHERE poe.date BETWEEN '" + start_date + "'  AND '" + end_date + "'
      AND poe.id=poed.part_of_equipment_id
      AND poe.cost_center_id = '" + cost_center.to_s + "'
      AND poe.equipment_id=sed.id
      AND poe.subcontract_equipment_id = " + working_group_id.to_s + "
      GROUP BY poe.equipment_id
    ")
    return last
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
      WHERE name LIKE '" + entityname.to_s + "'
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
      code,
      other_discount,
      accumulated_other_discount,
      totalbill,
      detraction
      FROM valuation_of_equipments 
      WHERE name LIKE '" + entityname.to_s + "' 
      AND code LIKE '" + code.to_s + "'
    ")
    return valuationgroup
  end

  def updateParts(start_date, end_date, id)
    ActiveRecord::Base.connection.execute("
      UPDATE part_of_equipments set block = 1 WHERE date BETWEEN '" + start_date + "' AND '" + end_date + "' AND subcontract_equipment_id=" + id.to_s + "
    ")
  end

  def create
    valuationofequipment = ValuationOfEquipment.new(valuation_of_equipment_parameters)
    valuationofequipment.state
    start_date = params[:valuation_of_equipment]['start_date']
    end_date = params[:valuation_of_equipment]['end_date']
    id =  Entity.find_by_name(params[:valuation_of_equipment]['name']).id
    if valuationofequipment.save
      updateParts(start_date,end_date,id)
      redirect_to :action => :index, company_id: params[:company_id]
    else
      valuationofequipment.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def destroy
    valuationofequipment = ValuationOfEquipment.destroy(params[:id])
    render :json => valuationofequipment
  end

  def part_equipment
    @action= params[:ac]
    @ids= params[:ids]
    @id = params[:id]
    @name = params[:name]
    @code = params[:code]
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @cad = params[:cad]
    @totalprice3 = 0
    @cc = get_company_cost_center('cost_center')
    @workers_array3 = business_days_array3(@start_date, @end_date, @cad,@cc)

    @workers_array5 = business_days_array5(@end_date,@cad,@cc)
    @art = Array.new
    @workers_array3.each do |workerDetail|
      @totalprice3 += workerDetail[4]
      @art << workerDetail[5]
    end
    @art = @art.join(',')
    if @art==''
      @art=0
    end

    @val1=ActiveRecord::Base.connection.execute("SELECT start_date,end_date FROM valuation_of_equipments WHERE name LIKE '" + @name + "' AND start_date < '" + @start_date + "'")

    #puts "-------1--------"
    if params[:id]==nil
    #puts "-------params id--------"
      if @val1.count!=0
        @workers_array6 = business_days_array6(@val1.to_a.first[0].to_s, @val1.to_a.last[1].to_s, @cad,@cc)
        #puts "--------workers_array6----"
        #puts @workers_array6.to_a
        #puts "------if-val.count--------"
        @thelast = @val1.to_a.last
        #puts "----thelast----"
        #puts @thelast
        #puts "---------------"
        @last_end = @start_date
        @cc = get_company_cost_center('cost_center')
        @last = last(@thelast[0].to_s,@thelast[1].to_s, @cad, @art, @cc)
        #puts "------@last count--"
        #puts @last.to_a
        #puts "------@last count end--"
        @try = "last"

      else
        #puts "------else------"
        @last = Array.new
        @workers_array3.each do |wa3|
          @last << [[0,0,0]]
        end
        #puts "------@last else ceros--"
        #puts @last.to_a
      end
    else
      @cc = get_company_cost_center('cost_center')
      @last_end =ValuationOfEquipment.find(params[:id]).start_date
      @last = last(@last_end, @cad, @art, @cc)
      #puts @last.count
      if @last.count==0
        @last=nil
        @last = Array.new
        @workers_array3.each do |wa3|
          @last << [[0,0,0]]
        end
      end
    end

    @array = Array.new
    @present = Array.new
    @past = Array.new
    @match = Array.new
    @notmatch = Array.new
    @notmatch2 = Array.new

    @workers_array3.each do |wa3|
      @present << wa3  
    end
    @last.each do |wa3|
      @past << wa3
    end

    @present.each do |pres|
      cont=0
      @past.each do |past|
        if pres[0]==past[0]
        #puts "------entra if pres[0]-----"
          cont+=1
          past[2]
          acumul=9
          @workers_array6.each do |acum|
            #puts"---acum--"
            #puts acum
            #puts "----pres[0]"
            #puts pres[0]
            #puts "----acum[0]---"
            #puts acum[0]
            #puts "----acum[1]--"
            #puts acum[1]
            if acum[0]==pres[0]
              #puts "----cumplio la igualdad--"
              acumul=acum[1]
            end
          end
          @match << (pres + [acumul]).to_a
          #puts "------@match-----"
          #puts @match
        end
      end
      if cont==0
        #puts "------entra else cont =0-----"
        @notmatch << (pres + [0]).to_a
      end
    end

    @array = @match + @notmatch

    render layout: false
  end

  def report_of_equipment
    @action = params[:ac]
    @totaldif = 0
    @totaltotalhours = 0
    @totalfuel_amount = 0
    @subcontractequipmentarticle= params[:subcontractequipment]
    @id= params[:id]
    @ids= params[:ids]
    @cad= params[:cad]
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @entityname = params[:name]
    @name2 = SubcontractEquipmentDetail.find_by_id(@subcontractequipmentarticle).code + ' ' + Article.find_article_by_global_article(SubcontractEquipmentDetail.find_by_id(@subcontractequipmentarticle).article_id ,session[:cost_center])
    puts @name2.inspect
    @poe_array = poe_array(@start_date, @end_date, @subcontractequipmentarticle, @entityname)
    @poe_array.each do |workerDetail|
      @totaldif += workerDetail[4].to_f
      @totaltotalhours += workerDetail[5].to_f
      @totalfuel_amount += workerDetail[7].to_f
    end
    @dias_habiles =  range_business_days(@start_date,@end_date)
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
  
  def poe_array(start_date, end_date, working_group_id,entity_name)
    @name = get_company_cost_center('cost_center')
    poe_array = ActiveRecord::Base.connection.execute("
      SELECT poe.code, poe.date, poe.initial_km, poe.final_km, poe.dif, poe.total_hours, art.name, poe.fuel_amount
      FROM part_of_equipments poe, articles_from_cost_center_" + @name.to_s + " art, subcontract_equipments sce
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

  def report_pdf
    respond_to do |format|
      format.html
      format.pdf do
        @company = Company.find(get_company_cost_center('company'))
        @valuationofequipment=ValuationOfEquipment.find_by_id(params[:id])
        @detraccion = @valuationofequipment.detraction
        @start_date = @valuationofequipment.start_date
        @end_date = @valuationofequipment.end_date
        @ids=params[:id]
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
            @descuentocombustible = workerDetail[7]
            @otrosdescuentos = workerDetail[8]
            @netoapagar = workerDetail[9]
          end
        end

        @cc = get_company_cost_center('cost_center')
        @inicio = ActiveRecord::Base.connection.execute("SELECT name FROM weeks_for_cost_center_"+get_company_cost_center('cost_center').to_s+" WHERE start_date <= '"+@start_date.to_s+"' AND end_date >= '"+@start_date.to_s+"'").first
        @fin = ActiveRecord::Base.connection.execute("SELECT name FROM weeks_for_cost_center_"+get_company_cost_center('cost_center').to_s+" WHERE start_date <= '"+@end_date.to_s+"' AND end_date >= '"+@end_date.to_s+"'").first
        
        render :pdf => "valorizacion_equipos_#{@valuationofequipment.code}-#{Time.now.strftime('%d-%m-%Y')}", 
               :template => 'production/valuation_of_equipments/report_pdf.pdf.haml',
               :page_size => 'Letter'
      end
    end
  end

  def part_equipment_pdf
    respond_to do |format|
      format.html
      format.pdf do
        puts "------------params id ----------------"
        @company = Company.find(get_company_cost_center('company'))
        @valuationofequipment=ValuationOfEquipment.find_by_id(params[:ids])
        @id = params[:id]
        @ids = params[:ids]
        @name = params[:name]
        @code = params[:code]
        @start_date = params[:start_date]
        @end_date = params[:end_date]
        @cad = params[:cad]
        @totalprice3 = 0
        @cc = get_company_cost_center('cost_center')
        @workers_array3 = business_days_array3(@start_date, @end_date, @cad,@cc)
        @workers_array5 = business_days_array5(@end_date,@cad,@cc)
        @art = Array.new
        @workers_array3.each do |workerDetail|
          @totalprice3 += workerDetail[4]
          @art << workerDetail[5]
        end
        @art = @art.join(',')
        if @art==''
          @art=0
        end

        @val1=ActiveRecord::Base.connection.execute("SELECT start_date,end_date FROM valuation_of_equipments WHERE name LIKE '" + @name + "' AND start_date < '" + @start_date + "'")


        puts "-------1--------"
        if params[:id]==nil
        puts "-------params id--------"
          if @val1.count!=0
            @workers_array6 = business_days_array6(@val1.to_a.first[0].to_s, @val1.to_a.last[1].to_s, @cad,@cc)
            puts "--------workers_array6----"
            puts @workers_array6.to_a
            puts "------if-val.count--------"
            @thelast = @val1.to_a.last
            puts "----thelast----"
            puts @thelast
            puts "---------------"
            @last_end = @start_date
            @cc = get_company_cost_center('cost_center')
            @last = last(@thelast[0].to_s,@thelast[1].to_s, @cad, @art, @cc)
            puts "------@last count--"
            puts @last.to_a
            puts "------@last count end--"
            @try = "last"

          else
            puts "------else------"
            @last = Array.new
            @workers_array3.each do |wa3|
              @last << [[0,0,0]]
            end
            puts "------@last else ceros--"
            puts @last.to_a
          end
        else
          @cc = get_company_cost_center('cost_center')
          @last_end =ValuationOfEquipment.find(params[:id]).start_date
          @last = last(@last_end, @cad, @art, @cc)
          puts @last.count
          if @last.count==0
            @last=nil
            @last = Array.new
            @workers_array3.each do |wa3|
              @last << [[0,0,0]]
            end
          end
        end

        @array = Array.new
        @present = Array.new
        @past = Array.new
        @match = Array.new
        @notmatch = Array.new
        @notmatch2 = Array.new

        @workers_array3.each do |wa3|
          @present << wa3  
        end
        @last.each do |wa3|
          @past << wa3
        end

        @present.each do |pres|
          cont=0
          @past.each do |past|
            if pres[0]==past[0]
            puts "------entra if pres[0]-----"
              cont+=1
              past[2]
              acumul=9
              @workers_array6.each do |acum|
                puts"---acum--"
                puts acum
                puts "----pres[0]"
                puts pres[0]
                puts "----acum[0]---"
                puts acum[0]
                puts "----acum[1]--"
                puts acum[1]
                if acum[0]==pres[0]
                  puts "----cumplio la igualdad--"
                  acumul=acum[1]
                end
              end
              @match << (pres + [acumul]).to_a
              puts "------@match-----"
              puts @match
            end
          end
          if cont==0
            puts "------entra else cont =0-----"
            @notmatch << (pres + [0]).to_a
          end
        end

        @array = @match + @notmatch


        render :pdf => "parte_equipos_#{@code}-#{Time.now.strftime('%d-%m-%Y')}", 
               :template => 'production/valuation_of_equipments/part_equipment_pdf.pdf.haml',
               :page_size => 'A4',
               :orientation => 'Landscape'
      end
    end
  end

  def report_of_equipment_pdf
    respond_to do |format|
      format.html
      format.pdf do
        @cc = get_company_cost_center('cost_center')
        @valuationofequipment = ValuationOfEquipment.find(params[:ids])
        @company = Company.find(get_company_cost_center('company'))
        @totaldif = 0
        @totaltotalhours = 0
        @totalfuel_amount = 0
        @subcontractequipmentarticle= params[:subcontractequipment]
        start_date = params[:start_date]
        end_date = params[:end_date]
        @entityname = params[:name]
        @name2 = SubcontractEquipmentDetail.find_by_id(@subcontractequipmentarticle).code + ' ' + Article.find_article_by_global_article(SubcontractEquipmentDetail.find_by_id(@subcontractequipmentarticle).article_id ,session[:cost_center])
        puts @name2.inspect
        @poe_array = poe_array(start_date, end_date, @subcontractequipmentarticle, @entityname)
        @poe_array.each do |workerDetail|
          @totaldif += workerDetail[4].to_f
          @totaltotalhours += workerDetail[5].to_f
          @totalfuel_amount += workerDetail[7].to_f
        end
        @dias_habiles =  range_business_days(start_date,end_date)
        render :pdf => "resumen_equipo_#{@name2}-#{Time.now.strftime('%d-%m-%Y')}", 
               :template => 'production/valuation_of_equipments/report_of_equipment_pdf.pdf.haml',
               :page_size => 'A4'
      end
    end
  end

  private
  def valuation_of_equipment_parameters
    params.require(:valuation_of_equipment).permit(
      :name, 
      :code, 
      :start_date, 
      :end_date, 
      :working_group, 
      :valuation, 
      :initial_amortization_number, 
      :initial_amortization_percentage, 
      :bill, 
      :billigv, 
      :totalbill, 
      :retention, 
      :other_discount, 
      :detraction, 
      :fuel_discount, 
      :othvaluation_of_equipmenter_discount, 
      :hired_amount, 
      :advances, 
      :accumulated_amortization, 
      :balance, 
      :net_payment, 
      :accumulated_valuation, 
      :accumulated_initial_amortization_number, 
      :accumulated_bill, 
      :accumulated_billigv, 
      :accumulated_totalbill, 
      :accumulated_retention, 
      :accumulated_detraction, 
      :accumulated_fuel_discount, 
      :accumulated_other_discount, 
      :accumulated_net_payment, 
      :subcontract_equipment_id
    )
  end
end