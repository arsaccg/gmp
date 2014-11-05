module ApplicationHelper
  def translate_delivery_order_state(str_value)
    str_spanish = ""
    case str_value
      when "pre_issued"
        str_spanish="PRE-EMITIDO"
      when "issued"
        str_spanish="EMITIDO"
      when "revised"
      	str_spanish="VISTO BUENO"
      when "canceled"
      	str_spanish="CANCELADO"
      when "approved"
        str_spanish="APROBADO"
    end
  end

  def translate_user_role(str_role)
    str_spanish = ""
    case str_role
      when "director"
        str_spanish="DIRECTOR"
      when "approver"
        str_spanish="APROBAR ORDENES DE SUMINISTRO"
      when "reviser"
        str_spanish="DAR VISTO BUENO A LAS ORDENES DE SUMINISTRO"
      when "canceller"
        str_spanish="CANCELAR ORDENES DE SUMINISTRO"
    end
  end

  def translate_purchase_order_state(str_value)
    str_spanish = ""
    case str_value
      when "pre_issued"
        str_spanish="PRE-EMITIDO"
      when "issued"
        str_spanish="EMITIDO"
      when "revised"
        str_spanish="VISTO BUENO"
      when "canceled"
        str_spanish="CANCELADO"
      when "approved"
        str_spanish="APROBADO"
    end
  end

  def translate_order_service_state(str_value)
    str_spanish = ""
    case str_value
      when "pre_issued"
        str_spanish="PRE-EMITIDO"
      when "issued"
        str_spanish="EMITIDO"
      when "revised"
        str_spanish="VISTO BUENO"
      when "canceled"
        str_spanish="CANCELADO"
      when "approved"
        str_spanish="APROBADO"
    end
  end

  def translate_valuations_state(str_value)
    str_spanish = ""
    case str_value
      when "disapproved"
        str_spanish="DESAPROBADO"
      when "approved"
        str_spanish="APROBADO"
    end
  end

  def get_next_state(str_state)
    str_spanish = ""
    case str_state
      when "pre_issued"
        str_spanish="issued"
      when "issued"
        str_spanish="revised"
      when "revised"
        str_spanish="approved"
    end
  end

  def get_prev_state(str_state)
    str_spanish = ""
    case str_state
      when "approved"
        str_spanish="revised"
      when "revised"
        str_spanish="issued"
      when "issued"
        str_spanish="observed"
    end
  end

  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end


  #~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~TOBI~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~*~#
  def get_total_cost(str_order, cost_center_id)
    items=ActiveRecord::Base.connection.execute("SELECT get_total_cost('#{str_order}', '#{cost_center_id}')")
    items.each do |item|
      return item[0]
    end
  end 
  
  def get_bugdet_cost(id)
    get_total_cost('', id)
  end
  
  def get_cost_partial(str_order)
    
    amount = 0
    amount = Inputbybudgetanditem.where("`order` LIKE ? ", str_order + "%").sum('price * quantity')
    
    return amount

  end 

  def get_total_metr(itembybudget_order)
    mtr = Itembybudget.where("`order` LIKE ?", itembybudget_order + "%").sum('measured')
  end 

  def get_espanol(month_en)
    hash = {'January' => 'Enero', 
      'February' => 'Febrero', 
      'March' => 'Marzo', 
      'April' => 'Abril',
      'May' => 'Mayo', 
      'June' => 'Junio', 
      'July' => 'Julio',
      'August' => 'Agosto',
      'September' => 'Septiembre',
      'October' => 'Octubre',
      'November' => 'Noviembre',
      'December' => 'Diciembre'}
    return hash[month_en]
  end

  def get_amount(codewbs)
    amount = 0
    items = Itembywbs.where("wbscode LIKE ? ", codewbs.to_s + "%")
    items.each do |item|
      amount =  amount + Inputbybudgetanditem.where("`coditem` LIKE ?", item.coditem + "%").sum('price * quantity')
    end
    
    return amount
  end

  def get_total_measured(codewbs)
     
    amount = Itembywbs.where("wbscode LIKE ? ", codewbs.to_s + "%").sum(:measured)
 
    return amount
  end

  def get_amount_items(coditem)
    amount = 0
      items = Itembywbs.where("`coditem` LIKE ?", coditem + "%")
      items.each do |item|
      amount =  amount + Inputbybudgetanditem.where("`coditem` LIKE ?", item.coditem + "%").sum('price * quantity')
    end
    
    return amount
  end
  
  def is_the_last(code_wbs)
    number_wbses = Wbsitem.where("codewbs LIKE ? ", code_wbs + "%").count
    
    if number_wbses == 1
      return true
    else
      return false
    end
  end
 

  def itemswbs_from_budget(id)
    array_asignals=Hash.new
    items_assigned = Itembywbs.where(:budget_id => id)
    items_assigned.each do |item|
      array_asignals[item.itembybudget_id] = 1
    end
    return array_asignals
  end

  def get_color_class(amount, id)

    if id != nil
      if amount.to_f == 0
        @color="color-class-red"
      end
      if amount.to_f>0
        @color="color-class-green"
      end
    else
      @color = "color-class-yellow"
    end
    
    
    return @color
  end

  def get_title_or_description(itembudget)
    str_item = "" 
    if itembudget.subbudgetdetail== nil || itembudget.subbudgetdetail==""
      str_item = itembudget.title rescue itembudget.item.description
    else 
      str_item = itembudget.subbudgetdetail 
    end
    return str_item 
  end
  def difference_days(date_s, date_f)
    #dias entre fecha 1 y 2
    days_between = (date_f.to_date-date_s.to_date) rescue 0
  end

  def get_credit(id)
    array_totals=Hash.new
    #result = ActiveRecord::Base.connection.execute("SELECT * FROM `itembywbses` WHERE (budget_id = '#{id}')")
    result = Itembywbs.where(:budget_id => id)
    result.each do |item|
      p item.inspect
      #array_totals[item[3] + item[4]] = array_totals[item[3] + item[4]].to_f + item[17].to_f 
      array_totals[item.coditem + item.order_budget] = array_totals[item.coditem + item.order_budget].to_f + item.measured.to_f
    end
    return array_totals 
  end


  #~# REPORT #~#
  #def get_sub_itembybudgets(orderitem, valorization_id)
  # #SELECT  itembybudgets.id, 
  # #        valorizationitems.id , 
  # #        subbudgetdetail, 
  # #        'UND', price, measured, 
  # #        (price * measured) AS 'total', 
  # #        IFNULL(get_prev_valorizations(valorizations.created_at, itembybudgets.id), 0) AS 'metrado_acumulado_anterior', 
  # #        IFNULL((get_prev_valorizations(valorizations.created_at, itembybudgets.id) * price), 0) AS 'costo_acumulado_anterior', 
  # #        valorizationitems.actual_measured, 
  # #        IFNULL((valorizationitems.actual_measured * price), 0) AS 'costo_actual',
  # #        IFNULL((get_prev_valorizations(valorizations.created_at, itembybudgets.id) + valorizationitems.actual_measured), 0) as 'metrado acumulado', 
  # #        IFNULL((get_prev_valorizations(valorizations.created_at, itembybudgets.id) + valorizationitems.actual_measured) * price, 0) as 'costo acumulado',
  # #        IFNULL(measured - (get_prev_valorizations(valorizations.created_at, itembybudgets.id) + valorizationitems.actual_measured), 0) AS 'saldo_metrado', 
  # #        IFNULL((measured - (get_prev_valorizations(valorizations.created_at, itembybudgets.id) + valorizationitems.actual_measured)) * price, 0) AS 'saldo_costo',
  # #        IFNULL(((get_prev_valorizations(valorizations.created_at, itembybudgets.id) + valorizationitems.actual_measured) / measured) * 100, 0) AS 'avance'
  # #FROM     `itembybudgets` LEFT JOIN
  # #        valorizationitems ON valorizationitems.itembybudget_id = itembybudgets.id LEFT JOIN 
  # #        valorizations ON valorizationitems.valorization_id = valorizations.id
  # #WHERE   `order` LIKE '02.01%' AND valorizations.id = '2';

  # #subitem = Itembybudget.joins("LEFT JOIN valorizationitems ON valorizationitems.itembybudget_id = itembybudgets.id").joins("LEFT JOIN valorizations ON valorizationitems.valorization_id = valorizations.id").select("itembybudgets.id, valorizationitems.id, subbudgetdetail, 'UND', price, measured, (price * measured) AS 'total', IFNULL(get_prev_valorizations(valorizations.created_at, itembybudgets.id), 0) AS 'metrado_acumulado_anterior', IFNULL((get_prev_valorizations(valorizations.created_at, itembybudgets.id) * price), 0) AS 'costo_acumulado_anterior', valorizationitems.actual_measured, IFNULL((valorizationitems.actual_measured * price), 0) AS 'costo_actual', IFNULL((get_prev_valorizations(valorizations.created_at, itembybudgets.id) + valorizationitems.actual_measured), 0) as 'metrado acumulado', IFNULL((get_prev_valorizations(valorizations.created_at, itembybudgets.id) + valorizationitems.actual_measured) * price, 0) as 'costo acumulado', IFNULL(measured - (get_prev_valorizations(valorizations.created_at, itembybudgets.id) + valorizationitems.actual_measured), 0) AS 'saldo_metrado', IFNULL((measured - (get_prev_valorizations(valorizations.created_at, itembybudgets.id) + valorizationitems.actual_measured)) * price, 0) AS 'saldo_costo', IFNULL(((get_prev_valorizations(valorizations.created_at, itembybudgets.id) + valorizationitems.actual_measured) / measured) * 100, 0) AS 'avance'").where("`order` LIKE (?) AND valorizations.id = (?)", '02.01%', '2')
  # orderi = orderitem + '%'

  # subitem = ActiveRecord::Base.connection.execute("call test_proc('01%', '2');")

  # return subitem
  #end

  def get_measured_item(valorization_id, itembudget)

    valorization_item = Valorizationitem.where("valorization_id = ? AND itembybudget_id = ?", valorization_id, itembudget).first

    return valorization_item.actual_measured rescue 0

  end

  def prev_valorizations(current_created_at, itembybudget_id)
    str_date = current_created_at.strftime("%Y-%m-%d  %T")
      items=ActiveRecord::Base.connection.execute("SELECT get_prev_valorizations('#{str_date}', '#{itembybudget_id}')")
    items.each do |item|
      return item[0]
    end
  end


  def amount_contractual(orderitem, budgetid)
      orderi = orderitem+'%'
      amount = Itembybudget.where('`order` LIKE (?) AND budget_id = (?) AND measured > 0', orderi, budgetid).sum('measured * price')
      return amount

      get_total_cost
  end

  def amount_prev(orderitem, budgetid, current_created_at)
      str_date = current_created_at.strftime("%Y-%m-%d  %T")
      items=ActiveRecord::Base.connection.execute("SELECT get_amount_prev('#{orderitem}', '#{budgetid}', '#{str_date}')")
    items.each do |item|
      return item[0]
    end
  end

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

  def amount_remainder(orderitem, budgetid, current_created_at, valorizationid)
      amount = amount_contractual(orderitem, budgetid) - amount_acumulated(orderitem, budgetid, current_created_at, valorizationid)
      return amount
  end

  def advance_percent(orderitem, budgetid, current_created_at, valorizationid)
        amount = 0 
      amount = amount_acumulated(orderitem, budgetid, current_created_at, valorizationid) / amount_contractual(orderitem, budgetid) * 100 rescue 0
      return amount
  end


  #~* admnistration/inputcategories  feo_of_work *~#
  #def sum_partial_sales(orderitem, budgetid)
    # orderi = '0' + orderitem + '%'
    # amount = Inputbybudgetanditem.where('`cod_input` LIKE (?) AND budget_id = (?)', orderi, budgetid).sum('quantity * price')
    # return amount
  #end

  def get_input_budget_item(orderitem, budgetid, wbs = nil)
      #SELECT input, SUM(quantity), price, cod_input, coditem FROM inputbybudgetanditems
    #WHERE `cod_input` LIKE '020205%' AND `budget_id` = 44
    #GROUP BY `coditem`
    ibi = nil 
      orderi = '0' + orderitem + '%'
      #ibi = Inputbybudgetanditem.where('`cod_input` LIKE (?) AND budget_id = (?)', orderi, budgetid)
      if wbs == nil
        ibi = Inputbybudgetanditem.select('input, SUM(quantity) as quantity, price, unit, cod_input').where('`cod_input` LIKE (?) AND budget_id = (?)', orderi, budgetid).group("cod_input")
      else

        hash_inputs = Hash.new
        total_inputs = Inputbybudgetanditem.where('cod_input LIKE ? AND budget_id = (?)', orderi, budgetid) 
        total_inputs.each do |input|
         
            if hash_inputs[input.order.to_s+input.item_id.to_s]  == nil 
            hash_inputs[input.order.to_s+input.item_id.to_s] =  Array.new
            hash_inputs[input.order.to_s+input.item_id.to_s] << input.id
          else
            hash_inputs[input.order.to_s+input.item_id.to_s] << input.id
          end
        end

        itembywbs = Itembywbs.where("wbscode LIKE ?", wbs + "%")

        ibi_temp = Array.new
        itembywbs.each do |item|
          inputs = hash_inputs[item.order_budget.to_s + item.id.to_s]
          if inputs !=nil
              inputs.each do |input|
                ibi_temp << input.id
              end
            end
          end
  
          ibi=Inputbybudgetanditem.select('input, SUM(quantity) as quantity, price, unit, cod_input').where("id IN (?) ", ibi_temp).group(:cod_input)
 
          
        end
       return ibi
      
  end

  def get_total_by_wbs(budgetid, wbs)
    amount = 0

      hash_inputs = Hash.new
        total_inputs = Inputbybudgetanditem.where('budget_id = (?)', budgetid)

        total_inputs.each do |input|
          before = hash_inputs[input.order.to_s+input.item_id.to_s] 
            if before != nil 
            hash_inputs[input.order.to_s+input.item_id.to_s] =  before.to_f + (input.price.to_f * input.quantity.to_f).to_f
          else
            hash_inputs[input.order.to_s+input.item_id.to_s] =  (input.price.to_f * input.quantity.to_f).to_f
          end
        end
      itembywbs = Itembywbs.where("wbscode LIKE ? AND budget_id = (?)", wbs + "%", budgetid)
          
        itembywbs.each do |item|
          amount =amount + (item.measured.to_f * (hash_inputs[item.order_budget.to_s+item.item_id.to_s]).to_f).to_f
          end

          return amount
  end

  def get_tr_class_feo(input, length)
    str_class=""
    case length
      when 2
        str_class = str_class + "first_" +input.category_id.to_s
      when 4
        str_class = str_class + "second_" +input.category_id.to_s
      when 6
        str_class = str_class + "third_" +input.category_id.to_s
    end
  end
   

  def get_sumatory_one_to_one(order, budget)
    total_sum = 0
    inputs = Inputbybudgetanditem.where("`order` LIKE ? AND budget_id = ? ", order + "%", budget)
    inputs.each do |item|
      price = item.price.to_f.round(4).to_s.to_f
      quantity = item.quantity.to_f.round(4).to_s.to_f
      partial = (price.round(4) * quantity.round(4)).round(2)

      total_sum = total_sum + partial.round(2)
    end
    return total_sum
  end


  def get_color_by_order(order)
    if order.length < 3
      return "red"
    elsif order.length < 6
      return "green"
    elsif order.length < 9
      return "blue"
    else
      return "black" 
    end
  end

  def get_clasification_by_order(order)
    if order.length < 3
      return "first"
    elsif order.length < 6
      return "second"
    elsif order.length < 9
      return "third"
    elsif order.length < 12
      return "fourth"
    elsif order.length < 15
      return "fifth"
    else
      return "sixth" 
    end
  end

end
