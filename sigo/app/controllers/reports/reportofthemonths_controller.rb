class Reports::ReportofthemonthsController < ApplicationController

  def index
  	@company = get_company_cost_center('company')
  	@d = Date.today-1.month
  	@dia = @d.at_beginning_of_month.strftime
  	@dia2 = @d.at_end_of_month.strftime
    @cost_center = get_company_cost_center('cost_center')

    @part_work = part_work(@dia, @dia2, @cost_center)
    @part_work.each do |workerDetail|
      @partwork = workerDetail[0]
    end
    @part_work2 = part_work2(@dia2, @cost_center)
    @part_work2.each do |workerDetail|
      @partwork2 = workerDetail[0]
    end

    @part_equipment = part_equipment(@dia, @dia2, @cost_center, '1', '8999')
    @part_equipment.each do |workerDetail|
      @partequipment = workerDetail[0]
    end
    @part_equipment2 = part_equipment2(@dia2, @cost_center, '1', '8999')
    @part_equipment2.each do |workerDetail|
      @partequipment2 = workerDetail[0]
    end

    @part_people = part_people(@dia, @dia2, @cost_center, '1', '8999')
    @part_people.each do |workerDetail|
      @partpeople = workerDetail[0]
    end
    @part_people2 = part_people2(@dia2, @cost_center, '1', '8999')
    @part_people2.each do |workerDetail|
      @partpeople2 = workerDetail[0]
    end

    @order_of_service = order_of_service(@dia, @dia2, @cost_center, '1', '8999')
    @order_of_service.each do |workerDetail|
      @orderofservice = workerDetail[0]
    end
    @order_of_service2 = order_of_service2(@dia2, @cost_center, '1', '8999')
    @order_of_service2.each do |workerDetail|
      @orderofservice2 = workerDetail[0]
    end

    @sc_valuations = sc_valuations(@dia, @dia2, @cost_center)
    @sc_valuations.each do |workerDetail|
      @scvaluations = workerDetail[0]
    end
    @sc_valuations2 = sc_valuations2(@dia2, @cost_center)
    @sc_valuations2.each do |workerDetail|
      @scvaluations2 = workerDetail[0]
    end
   
    @part_equipment3 = part_equipment(@dia, @dia2, @cost_center, '9000', '9299')
    @part_equipment3.each do |workerDetail|
      @partequipment3 = workerDetail[0]
    end
    @part_equipment4 = part_equipment2(@dia2, @cost_center, '9000', '9299')
    @part_equipment4.each do |workerDetail|
      @partequipment4 = workerDetail[0]
    end

    @part_people3 = part_people(@dia, @dia2, @cost_center, '9000', '9299')
    @part_people3.each do |workerDetail|
      @partpeople3 = workerDetail[0]
    end
    @part_people4 = part_people2(@dia2, @cost_center, '9000', '9299')
    @part_people4.each do |workerDetail|
      @partpeople4 = workerDetail[0]
    end

    @order_of_service3 = order_of_service(@dia, @dia2, @cost_center, '9000', '9299')
    @order_of_service3.each do |workerDetail|
      @orderofservice3 = workerDetail[0]
    end
    @order_of_service4 = order_of_service2(@dia2, @cost_center, '9000', '9299')
    @order_of_service4.each do |workerDetail|
      @orderofservice4 = workerDetail[0]
    end

    @part_equipment5 = part_equipment(@dia, @dia2, @cost_center, '9410', '9410')
    @part_equipment5.each do |workerDetail|
      @partequipment5 = workerDetail[0]
    end
    @part_equipment6 = part_equipment2(@dia2, @cost_center, '9410', '9410')
    @part_equipment6.each do |workerDetail|
      @partequipment6 = workerDetail[0]
    end

    @part_people5 = part_people(@dia, @dia2, @cost_center, '9410', '9410')
    @part_people5.each do |workerDetail|
      @partpeople5 = workerDetail[0]
    end
    @part_people6 = part_people2(@dia2, @cost_center, '9410', '9410')
    @part_people6.each do |workerDetail|
      @partpeople6 = workerDetail[0]
    end

    @order_of_service5 = order_of_service(@dia, @dia2, @cost_center, '9410', '9410')
    @order_of_service5.each do |workerDetail|
      @orderofservice5 = workerDetail[0]
    end
    @order_of_service6 = order_of_service2(@dia2, @cost_center, '9410', '9410')
    @order_of_service6.each do |workerDetail|
      @orderofservice6 = workerDetail[0]
    end

    @part_equipment7 = part_equipment(@dia, @dia2, @cost_center, '9420', '9420')
    @part_equipment7.each do |workerDetail|
      @partequipment7 = workerDetail[0]
    end
    @part_equipment8 = part_equipment2(@dia2, @cost_center, '9420', '9420')
    @part_equipment8.each do |workerDetail|
      @partequipment8 = workerDetail[0]
    end

    @part_people7 = part_people(@dia, @dia2, @cost_center, '9420', '9420')
    @part_people7.each do |workerDetail|
      @partpeople7 = workerDetail[0]
    end
    @part_people8 = part_people2(@dia2, @cost_center, '9420', '9420')
    @part_people8.each do |workerDetail|
      @partpeople8 = workerDetail[0]
    end

    @order_of_service7 = order_of_service(@dia, @dia2, @cost_center, '9420', '9420')
    @order_of_service7.each do |workerDetail|
      @orderofservice7 = workerDetail[0]
    end
    @order_of_service8 = order_of_service2(@dia2, @cost_center, '9420', '9420')
    @order_of_service8.each do |workerDetail|
      @orderofservice8 = workerDetail[0]
    end

    # Venta Valorizada y Venta Programado
    @acumulated_valorized_sale_current_month = 0
    @gg_valorized_sale_current_month = 0

    @acumulated_scheduled_sale_current_month = 0
    @gg_scheduled_sale_current_month = 0

    @sale_goal = Array.new
    4.times do |i|
      i += 1
      # Valorizado
      current_valorized = get_valorized_sale(i, @cost_center) rescue 0
      # Programado
      current_scheduled = get_planned_sale(i, @cost_center) rescue 0
      
      # Acumulado Valorizado
      @acumulated_valorized_sale_current_month += current_valorized
      # Acumulado Programado
      @acumulated_scheduled_sale_current_month += current_scheduled

      # Arreglo total del VENTA
      # 0 => Venta Programado de la fecha
      # 1 => Venta Programado acumulado hasta la fecha
      # 2 => Venta Valorizado de la fecha
      # 3 => Venta Valorizado acumulado hasta la fecha
      @sale_goal << [current_scheduled, current_scheduled, current_valorized, current_valorized]
    end

    # Costo Meta (Con la valorizacion de los presupuestos Meta) y el Costo Real
    @acumulated_cost_goal_current_month = 0
    @gg_cost_goal_current_month = 0
    @cost_goal_current_month = 0
    @cost_goal = Array.new
    # Cost_Goal Have
    # [1] => Costo Directo Actual
    # [2] => Costo Directo Acumulado
    # [3] => Costo Meta Actual
    # [4] => Costo Meta Acummulado
    # Each row is differente by MO, MAT, EQ, SC y SERV.

    4.times do |j|
      j += 1
      current_cost = get_cost_goal(j, @cost_center)
      if j == 1
        @cost_goal << [@partpeople, @partpeople2, current_cost]
      elsif j == 2
        @cost_goal << [@partwork, @partwork2, current_cost]
      elsif j == 3
        @cost_goal << [@partequipment, @partequipment2, current_cost]
      elsif j == 4
        @cost_goal << [@orderofservice + @scvaluations, @orderofservice2 + @scvaluations, current_cost]
      end
      @acumulated_cost_goal_current_month += current_cost
    end

    # Gastos Generales ¿percent o calculated?
    overhead_percentage = CostCenter.find(@cost_center).overhead_percentage
    if overhead_percentage != nil
      @gg_valorized_sale_current_month = @acumulated_valorized_sale_current_month*overhead_percentage
      @gg_scheduled_sale_current_month = @acumulated_scheduled_sale_current_month*overhead_percentage
      @gg_cost_goal_current_month = @gg_cost_goal_current_month*overhead_percentage
    end

		render layout: false
  end

  # Helper Functions

  def part_work(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT getPartWork('" + start_date + "','" + end_date + "', " + working_group_id + ") FROM DUAL
    ")
    return workers_array3
  end

  def part_work2(end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT getPartWork2('" + end_date + "', " + working_group_id + ") FROM DUAL
    ")
    return workers_array3
  end

  def part_equipment(start_date, end_date, working_group_id, phase_id, phase_id2)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT partEquipment('" + start_date + "','" + end_date + "', " + working_group_id + ", " + phase_id + ", " + phase_id2 + ") FROM DUAL
    ")
    return workers_array3
  end

  def part_equipment2(end_date, working_group_id, phase_id, phase_id2)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT partEquipment2('" + end_date + "', " + working_group_id + ", " + phase_id + ", " + phase_id2 + ") FROM DUAL
    ")
    return workers_array3
  end

  def part_people(start_date, end_date, working_group_id, phase_id, phase_id2)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT partPeople('" + start_date + "','" + end_date + "', " + working_group_id + ", " + phase_id + ", " + phase_id2 + ") FROM DUAL
    ")
    return workers_array3
  end

  def part_people2(end_date, working_group_id, phase_id, phase_id2)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT partPeople2('" + end_date + "', " + working_group_id + ", " + phase_id + ", " + phase_id2 + ") FROM DUAL
    ")
    return workers_array3
  end

  def order_of_service(start_date, end_date, working_group_id, phase_id, phase_id2)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT orderOfService('" + start_date + "','" + end_date + "', " + working_group_id + ", " + phase_id + ", " + phase_id2 + ") FROM DUAL
    ")
    return workers_array3
  end

  def order_of_service2(end_date, working_group_id, phase_id, phase_id2)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT orderOfService2('" + end_date + "', " + working_group_id + ", " + phase_id + ", " + phase_id2 + ") FROM DUAL
    ")
    return workers_array3
  end

  def sc_valuations(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT scValuations('" + start_date + "','" + end_date + "'," + working_group_id + ") FROM DUAL
    ")
    return workers_array3
  end

  def sc_valuations2(end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT scValuations2('" + end_date + "'," + working_group_id + ") FROM DUAL
    ")
    return workers_array3
  end


  # Venta Valorizada

  def get_valorized_sale(type_article, cost_center_id)
    result = ""
    mysql_result = ActiveRecord::Base.connection.execute("SELECT get_valorized_sale(" +  type_article.to_s + "," + cost_center_id.to_s + ") FROM DUAL;")
    mysql_result.each do |mysql|
      result = mysql[0]
    end
    return result
  end

  # Venta programada

  def get_planned_sale(type_article, cost_center_id)
    result = ""
    mysql_result = ActiveRecord::Base.connection.execute("SELECT get_scheduled_sale(" + type_article.to_s + "," + cost_center_id.to_s + ") FROM DUAL;")
    mysql_result.each do |mysql|
      result = mysql[0]
    end
    return result
  end

  # Costo Meta
  def get_cost_goal(type_article, cost_center_id)
    result = ""
    mysql_result = ActiveRecord::Base.connection.execute("SELECT get_cost_goal(" +  type_article.to_s + "," + cost_center_id.to_s + ") FROM DUAL;")
    mysql_result.each do |mysql|
      result = mysql[0]
    end
    return result
  end

end
