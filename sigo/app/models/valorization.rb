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
    str_query = "SELECT  itembybudgets.id, 
        valorizationitems.id , 
            itembybudgets.`order` AS 'order_item',
        subbudgetdetail, 
        'UND', price, measured, 
        (price * measured) AS 'total', 
        IFNULL((valorizationitems.accumulated_measured - valorizationitems.actual_measured), '--') AS 'metrado_acumulado_anterior', 
        IFNULL(((valorizationitems.accumulated_measured - valorizationitems.actual_measured) * price), '--') AS 'costo_acumulado_anterior', 
        valorizationitems.actual_measured, 
        IFNULL((valorizationitems.actual_measured * price), '--') AS 'costo_actual',
        IFNULL(valorizationitems.accumulated_measured, '--') as 'metrado acumulado', 
        IFNULL((valorizationitems.accumulated_measured * price), '--') as 'costo acumulado',
        IFNULL(measured - (IFNULL(valorizationitems.accumulated_measured, 0)), '--') AS 'saldo_metrado', 
        IFNULL((measured - valorizationitems.accumulated_measured) * price, '--') AS 'saldo_costo',
        IFNULL((IFNULL(valorizationitems.accumulated_measured, 0) / measured) * 100, 0) AS 'avance'
        FROM     `itembybudgets` LEFT JOIN
        valorizationitems ON valorizationitems.itembybudget_id = itembybudgets.id LEFT JOIN 
        valorizations ON valorizationitems.valorization_id = valorizations.id
        WHERE   `order` LIKE '" + orderi + "' AND valorizations.id = '" + valorization_id + "'"
    
    #ActiveRecord::Base.connection.reconnect!
    #subitem = ActiveRecord::Base.connection.select_all("call test_proc('01%', '2');")
    
    results = ActiveRecord::Base.connection.execute(str_query) 
    return results
  end

end
