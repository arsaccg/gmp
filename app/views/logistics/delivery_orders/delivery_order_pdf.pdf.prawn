text "ORDEN DE SUMINISTRO - #{@deliveryOrder.id.to_s.rjust(5, '0')}", :align => :center

move_down 20

table([ ["CENTRO DE COSTO", ""], ["EMITIDO POR", "#{@deliveryOrder.user.first_name + ' ' + @deliveryOrder.user.last_name}", "FECHA EMISIÓN", "#{@deliveryOrder.date_of_issue.strftime("%d/%m/%Y")}"], ["ESTADO", "#{translate_delivery_order_state(@deliveryOrder.state)}", "FECHA A ATENDER", "#{@deliveryOrder.scheduled.strftime("%d/%m/%Y")}"] ], :width => 530, :column_widths => [150])

move_down 20

table([ ["ITEM", "CÓDIGO", "DESCRIPCIÓN", "SECTOR", "FASE", "U.M", "CANTIDAD"] ], :width => 530)

move_down 30

text "Glosa", :style => :bold
text "#{@deliveryOrder.description}"