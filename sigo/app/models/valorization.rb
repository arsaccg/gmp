class Valorization < ActiveRecord::Base
	belongs_to :budget
	has_many :invoices

    state_machine :status, :initial => :pending do

      event :semicomplete do
        transition :pending => :partial
      end
      event :complete do
        transition :partial => :charged
      end
    end

  def self.get_sub_itembybudgets(orderitem, valorization_id, budget_id)
    orderi = orderitem + '%'
    # str_query = "SELECT  itembybudgets.id, 
    #     valorizationitems.id , 
    #         itembybudgets.`order` AS 'order_item',
    #     subbudgetdetail, 
    #     'UND', price, measured, 
    #     (price * measured) AS 'total', 
    #     IFNULL((valorizationitems.accumulated_measured - valorizationitems.actual_measured), '--') AS 'metrado_acumulado_anterior', 
    #     IFNULL(((valorizationitems.accumulated_measured - valorizationitems.actual_measured) * price), '--') AS 'costo_acumulado_anterior', 
    #     valorizationitems.actual_measured, 
    #     IFNULL((valorizationitems.actual_measured * price), '--') AS 'costo_actual',
    #     IFNULL(valorizationitems.accumulated_measured, '--') as 'metrado acumulado', 
    #     IFNULL((valorizationitems.accumulated_measured * price), '--') as 'costo acumulado',
    #     IFNULL(measured - (IFNULL(valorizationitems.accumulated_measured, 0)), measured) AS 'saldo_metrado', 
    #     IFNULL((measured - valorizationitems.accumulated_measured) * price, (price * measured)) AS 'saldo_costo',
    #     IFNULL((IFNULL(valorizationitems.accumulated_measured, 0) / measured) * 100, 100) AS 'avance'
    #     FROM     `itembybudgets` LEFT JOIN
    #     valorizationitems ON valorizationitems.itembybudget_id = itembybudgets.id LEFT JOIN 
    #     valorizations ON valorizationitems.valorization_id = valorizations.id
    #     WHERE   `order` LIKE '" + orderi + "' AND valorizations.id = '" + valorization_id + "'"
    str_query = "SELECT  itembybudgets.id, 
        valorizationitems.id , 
            itembybudgets.`order` AS 'order_item',
        subbudgetdetail, 
        'UND', price, measured, 
        (price * measured) AS 'total', 
        '--' AS 'metrado_acumulado_anterior', 
        '--' AS 'costo_acumulado_anterior', 
        valorizationitems.actual_measured, 
        IFNULL((valorizationitems.actual_measured * price), '--') AS 'costo_actual',
        IFNULL(valorizationitems.accumulated_measured, '--') as 'metrado acumulado', 
        IFNULL((valorizationitems.accumulated_measured * price), '--') as 'costo acumulado',
        IFNULL(measured - (IFNULL(valorizationitems.accumulated_measured, 0)), measured) AS 'saldo_metrado', 
        IFNULL((measured - valorizationitems.accumulated_measured) * price, (price * measured)) AS 'saldo_costo',
        IFNULL((IFNULL(valorizationitems.accumulated_measured, 0) / measured) * 100, 100) AS 'avance'
        FROM     `itembybudgets` LEFT JOIN
        valorizationitems ON valorizationitems.itembybudget_id = itembybudgets.id LEFT JOIN 
        valorizations ON valorizationitems.valorization_id = valorizations.id
        WHERE   `order` LIKE '" + orderi + "' AND valorizations.id = '" + valorization_id + "'"
    
    #ActiveRecord::Base.connection.reconnect!
    #subitem = ActiveRecord::Base.connection.select_all("call test_proc('01%', '2');")
    
    results = ActiveRecord::Base.connection.execute(str_query) 
    return results
  end


  def self.get_sub_itembybudgets_short(orderitem, valorization_id, budget_id)
    orderi = orderitem + '%'
    str_query = "SELECT  itembybudgets.id, 
        valorizationitems.id , 
            itembybudgets.`order` AS 'order_item',
        subbudgetdetail, 
        'UND', price, measured, 
        (price * measured) AS 'total', 
        '--' AS 'metrado_acumulado_anterior', 
        '--' AS 'costo_acumulado_anterior', 
        valorizationitems.actual_measured, 
        IFNULL((valorizationitems.actual_measured * price), '--') AS 'costo_actual',
        IFNULL(valorizationitems.accumulated_measured, '--') as 'metrado acumulado', 
        IFNULL((valorizationitems.accumulated_measured * price), '--') as 'costo acumulado',
        IFNULL(measured - (IFNULL(valorizationitems.accumulated_measured, 0)), measured) AS 'saldo_metrado', 
        IFNULL((measured - valorizationitems.accumulated_measured) * price, (price * measured)) AS 'saldo_costo',
        IFNULL((IFNULL(valorizationitems.accumulated_measured, 0) / measured) * 100, 100) AS 'avance'
        FROM     `itembybudgets`, `valorizationitems`, `valorizations`
        WHERE valorizationitems.itembybudget_id = itembybudgets.id
        AND valorizationitems.valorization_id = valorizations.id
        AND   `order` LIKE '" + orderi + "' AND valorizations.id = '" + valorization_id + "'"
    
    #ActiveRecord::Base.connection.reconnect!
    #subitem = ActiveRecord::Base.connection.select_all("call test_proc('01%', '2');")
    
    results = ActiveRecord::Base.connection.execute(str_query) 
    return results
  end





  def self.advance_percent(orderitem, budgetid, current_created_at, valorizationid)
      amount = 0 
      amount = amount_acumulated(orderitem, budgetid, current_created_at, valorizationid) / amount_contractual(orderitem, budgetid) * 100
      return amount
  end

  def self.amount_contractual(orderitem, budgetid)
      orderi = orderitem+'%'
      amount = Itembybudget.where('`order` LIKE (?) AND budget_id = (?) AND measured > 0', orderi, budgetid).sum('measured * price')
      return amount

      get_total_cost
  end

  def self.amount_prev(orderitem, budgetid, current_created_at)
      str_date = current_created_at.strftime("%Y-%m-%d  %T")
      items=ActiveRecord::Base.connection.execute("SELECT get_amount_prev('#{orderitem}', '#{budgetid}', '#{str_date}')")
    items.each do |item|
      return item[0]
    end
  end

  def self.amount_actual(orderitem, budgetid, valorizationid)
      items=ActiveRecord::Base.connection.execute("SELECT get_amount_actual('#{orderitem}', '#{budgetid}', '#{valorizationid}')")
    items.each do |item|
      return item[0]
    end
  end

  def self.amount_acumulated(orderitem, budget_id, current_created_at, valorizationid)
    str_date = current_created_at.strftime("%Y-%m-%d  %T")
      items=ActiveRecord::Base.connection.execute("SELECT get_amount_acumulated('#{orderitem}', '#{budget_id}', '#{str_date}', '#{valorizationid}')")
    items.each do |item|
      return item[0]
    end
  end

  def self.amount_remainder(orderitem, budgetid, current_created_at, valorizationid)
      amount = amount_contractual(orderitem, budgetid) - amount_acumulated(orderitem, budgetid, current_created_at, valorizationid)
      return amount
  end

  def self.advance_percent(orderitem, budgetid, current_created_at, valorizationid)
      amount = 0 
      amount = amount_acumulated(orderitem, budgetid, current_created_at, valorizationid) / amount_contractual(orderitem, budgetid) * 100 rescue 0
      return amount
  end

end
