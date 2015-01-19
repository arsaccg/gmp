class Reports::ReportofthemonthsController < ApplicationController

  def index
  	@company = get_company_cost_center('company')
  	@d = Date.today-1.month
  	@dia = @d.at_beginning_of_month.strftime
  	@dia2 = @d.at_end_of_month.strftime
    @cost_center = session[:cost_center]

    @partwork = 0 
    @partequipment = 0
    @partpeople = 0
    @orderofservice = 0
    @scvaluations = 0
    @partwork2 = 0
    @partequipment2 = 0
    @partpeople2 = 0
    @orderofservice2 = 0
    @scvaluations2 = 0
    @partequipment3 = 0
    @partpeople3 = 0
    @orderofservice3 = 0
    @partequipment4 = 0
    @partpeople4 = 0
    @orderofservice4 = 0
    @partequipment5 = 0
    @partpeople5 = 0
    @orderofservice5 = 0
    @partequipment6 = 0
    @partpeople6 = 0
    @orderofservice6 = 0
    @partequipment7 = 0
    @partpeople7 = 0
    @orderofservice7 = 0
    @partequipment8 = 0
    @partpeople8 = 0
    @orderofservice8 = 0

    # => FECHAS PARA LOS GRAFICOS
    
    @months_linear_char = Array.new
    @months_bar_char = Array.new
    current_month = Time.now

    @months_linear_char << ((current_month.strftime('%^b.%Y')).gsub 'JAN', 'ENE')
    @months_bar_char << ((current_month.strftime('%^b.%Y')).gsub 'JAN', 'ENE')

    7.times do |j|
      @months_linear_char << ((( current_month - (j+1).month ).strftime('%^b.%Y')).gsub 'JAN', 'ENE')
    end

    5.times do |j|
      @months_bar_char << ((( current_month - (j+1).month ).strftime('%^b.%Y')).gsub 'JAN', 'ENE')
    end

    @months_linear_char = @months_linear_char.reverse
    @months_bar_char = @months_bar_char.reverse

    # => TERMINA FECHAS PARA LOS GRAFICOS

    # Venta Valorizada y Venta Programado
    @acumulated_valorized_sale_current_month = 0
    @gg_valorized_sale_current_month = 0

    @acumulated_scheduled_sale_current_month = 0
    @gg_scheduled_sale_current_month = 0

    @sale_goal = Array.new

    # Costo Meta (Con la valorizacion de los presupuestos Meta) y el Costo Real
    @acumulated_cost_goal_current_month = 0
    @gg_cost_goal_current_month = 0
    @cost_goal_current_month = 0
    @cost_goal = Array.new
    # Cost_Goal Have

    # Gastos Generales ¿percent o calculated?
    overhead_percentage = CostCenter.find(@cost_center).overhead_percentage rescue nil
    if overhead_percentage != nil
      @gg_valorized_sale_current_month = @acumulated_valorized_sale_current_month*overhead_percentage
      @gg_scheduled_sale_current_month = @acumulated_scheduled_sale_current_month*overhead_percentage
      @gg_cost_goal_current_month = @gg_cost_goal_current_month*overhead_percentage
    end

    # VALORES para los GRÁFICOS
    @start_date_cost_center = CostCenter.find(@cost_center).start_date
    @now = Time.now
    
    if @start_date_cost_center.nil?
      @start_date_cost_center = @now
    end

    target = 0
    @values_y_axis = Array.new
    @values_x_axis = Array.new

    @acumulates_real_cost_current_month = (@partwork2.to_f + @partequipment2.to_f + @partpeople2.to_f + @orderofservice2.to_f + @scvaluations2.to_f)
    
    if @acumulated_valorized_sale_current_month > @acumulates_real_cost_current_month
      target = @acumulated_valorized_sale_current_month
    else
      target = @acumulates_real_cost_current_month
    end

    3.times do |month|
      @values_x_axis << @start_date_cost_center.strftime('%b-%Y')
      @now -= 1.months
      if @now < @start_date_cost_center
        break
      end
    end

    @values_y_axis = [*0..target].sample(11).sort

    # =>  VALORIZACIONES

    @data_total_valorization_linear_char = Array.new(@months_linear_char.count)
    @data_total_valorization_bar_char = Array.new(@months_bar_char.count)

    Valorization.all.each do |valorization|
      total_valorization = 0
      @direct_cost_acc = 0
      @budget = Budget.where(:id => valorization.budget_id).first
      @itembybudgets_main = Itembybudget.select('id, `title`, `subbudgetdetail`, `order`, CHAR_LENGTH(`order`)').where('CHAR_LENGTH(`order`) < 3 AND budget_id = ?', valorization.budget_id)
      #Valorizationitem.where(:valorization_id => valorization.id).each do |valorization_item|
        #measure = valorization_item.actual_measured.to_f
        #price = Itembybudget.where(:id => valorization_item.itembybudget_id).first.price.to_f rescue 0
        #total_valorization += (measure.to_f * price.to_f)
      
      @itembybudgets_main.each do |ib|        
        c_amount_acc = amount_acumulated(ib.order, @budget.id, valorization.valorization_date, valorization.id)
        @direct_cost_acc = @direct_cost_acc + c_amount_acc 
      end

      total_valorization = (@direct_cost_acc + (@direct_cost_acc * @budget.general_expenses.to_f) + (@direct_cost_acc * @budget.utility.to_f)).round(2)
      
      pos_linear = @months_linear_char.index(valorization.valorization_date.to_date.strftime('%^b.%Y').to_s).to_i
      pos_bar = @months_bar_char.index(valorization.valorization_date.to_date.strftime('%^b.%Y').to_s).to_i
      @data_total_valorization_linear_char[pos_linear] =  total_valorization.to_f
      @data_total_valorization_bar_char[pos_bar] = total_valorization.to_f
    end

    @data_total_valorization_linear_char.map! { |v| v.nil? ? 0 : v }
    if @data_total_valorization_linear_char.last == 0
      @data_total_valorization_linear_char.pop
      if @data_total_valorization_linear_char.last == 0
        @data_total_valorization_linear_char.pop
      end
    end
    @data_total_valorization_bar_char.map! { |v| v.nil? ? 0 : v }

    # => Por ahora, solo cojo la ultima valorizacion
    @valorization = Valorization.last
    @direct_cost_act = 0
    @direct_cost_acc = 0
    Itembybudget.select('id, `title`, `subbudgetdetail`, `order`, CHAR_LENGTH(`order`)').where('CHAR_LENGTH(`order`) < 3 AND budget_id = ?', @valorization.budget_id).each do |ib|
      @budget = Budget.where(:id => @valorization.budget_id).first
      c_amount_act = amount_actual(ib.order, @budget.id, @valorization.id)
      @direct_cost_act = @direct_cost_act + c_amount_act 
   
      c_amount_acc = amount_acumulated(ib.order, @budget.id, @valorization.valorization_date, @valorization.id)
      @direct_cost_acc = @direct_cost_acc + c_amount_acc
    end

    # => VALORIZACIONES

		render layout: false
  end

  # Helper Functions

  def part_work(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT getPartWork('" + start_date + "','" + end_date + "', " + working_group_id.to_s + ") FROM DUAL
    ")
    return workers_array3
  end

  def part_work2(end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT getPartWork2('" + end_date + "', " + working_group_id.to_s + ") FROM DUAL
    ")
    return workers_array3
  end

  def part_equipment(start_date, end_date, working_group_id, phase_id, phase_id2)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT partEquipment('" + start_date + "','" + end_date + "', " + working_group_id.to_s + ", " + phase_id.to_s + ", " + phase_id2.to_s + ") FROM DUAL
    ")
    return workers_array3
  end

  def part_equipment2(end_date, working_group_id, phase_id, phase_id2)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT partEquipment2('" + end_date + "', " + working_group_id.to_s + ", " + phase_id.to_s + ", " + phase_id2.to_s + ") FROM DUAL
    ")
    return workers_array3
  end

  def part_people(start_date, end_date, working_group_id, phase_id, phase_id2)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT partPeople('" + start_date + "','" + end_date + "', " + working_group_id.to_s + ", " + phase_id.to_s + ", " + phase_id2.to_s + ") FROM DUAL
    ")
    return workers_array3
  end

  def part_people2(end_date, working_group_id, phase_id, phase_id2)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT partPeople2('" + end_date + "', " + working_group_id.to_s + ", " + phase_id.to_s + ", " + phase_id2.to_s + ") FROM DUAL
    ")
    return workers_array3
  end

  def order_of_service(start_date, end_date, working_group_id, phase_id, phase_id2)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT orderOfService('" + start_date + "','" + end_date + "', " + working_group_id.to_s + ", " + phase_id.to_s + ", " + phase_id2.to_s + ") FROM DUAL
    ")
    return workers_array3
  end

  def order_of_service2(end_date, working_group_id, phase_id, phase_id2)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT orderOfService2('" + end_date + "', " + working_group_id.to_s + ", " + phase_id.to_s + ", " + phase_id2.to_s + ") FROM DUAL
    ")
    return workers_array3
  end

  def sc_valuations(start_date, end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT scValuations('" + start_date + "','" + end_date + "'," + working_group_id.to_s + ") FROM DUAL
    ")
    return workers_array3
  end

  def sc_valuations2(end_date, working_group_id)
    workers_array3 = ActiveRecord::Base.connection.execute("
      SELECT scValuations2('" + end_date + "'," + working_group_id.to_s + ") FROM DUAL
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

  # => SOME METHODS FROM Application Helper duplicate : amount_acumulated, amount_actual
  
  def amount_actual(orderitem, budgetid, valorizationid)
      items=ActiveRecord::Base.connection.execute("SELECT get_amount_actual('#{orderitem}', '#{budgetid}', '#{valorizationid}')")
    items.each do |item|
      return item[0]
    end
  end

  def amount_acumulated(orderitem, budget_id, current_created_at, valorizationid)
    str_date = current_created_at.strftime("%Y-%m-%d  %T")
      items=ActiveRecord::Base.connection.execute("SELECT get_amount_acumulated('#{orderitem}', '#{budget_id}', '#{str_date}', '#{valorizationid}')")
    items.each do |item|
      return item[0]
    end
  end

end
