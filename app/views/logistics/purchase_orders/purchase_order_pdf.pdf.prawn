text "ORDEN DE COMPRA - #{@purchaseOrder.id.to_s.rjust(5, '0')}", :align => :center

move_down 20

table([ ["PROVEEDOR", "#{@purchaseOrder.supplier.ruc} - #{@purchaseOrder.supplier.name}"] ], :width => 540, :column_widths => [140])
table([ ["CENTRO DE COSTO", "#{@purchaseOrder.cost_center.name}"] ], :width => 540, :column_widths => [140])
table([ ["FORMA DE PAGO", "#{@purchaseOrder.method_of_payment.name}", "O/Suministro", "#{@deliveryOrders.map(&:inspect).join(', ')}", "FECHA EMISIÓN", "#{@purchaseOrder.date_of_issue.strftime("%d/%m/%Y")}"] ], :width => 540, :column_widths => [140])
table([ ["ESTADO", "#{translate_purchase_order_state(@purchaseOrder.state)}", "FECHA A ATENDER", "#{@purchaseOrder.delivery_date.strftime("%d/%m/%Y")}"] ], :width => 540, :column_widths => [140])

move_down 20

table([ ["ITEM", "CÓDIGO", "DESCRIPCIÓN    At. Sector FASE", "U.M", "CANTIDAD", "PRECIO UNITARIO", "% Dscto", "SUBTOTAL"] ], :width => 540)

move_down 3

@purchaseOrderDetails.each do |data|
  stroke_horizontal_rule
  pad(5) {
    text "          #{data.id}             #{data.delivery_order_detail.article.code}       #{data.delivery_order_detail.article.name}                                                 #{data.delivery_order_detail.center_of_attention.abbreviation}    #{data.delivery_order_detail.sector.code}      #{data.delivery_order_detail.phase.code}      #{data.delivery_order_detail.unit_of_measurement.symbol}       #{data.delivery_order_detail.amount}"
    move_down 4
    text "#{data.description}"
  }
  stroke_horizontal_rule
  move_down 3
end

move_down 40

text "Glosa", :style => :bold
text "#{@purchaseOrder.description}"

repeat :all do
   bounding_box [bounds.left, bounds.bottom + 50], :width  => bounds.width do
    table([ 
      ["#{@state_per_order_purchase_approved.user.first_name + ' ' + @state_per_order_purchase_approved.user.last_name + ' ' + @state_per_order_purchase_approved.user.surname }", "#{@state_per_order_purchase_revised.user.first_name + ' ' + @state_per_order_purchase_revised.user.last_name + ' ' + @state_per_order_purchase_revised.user.surname }"], ["#{@first_state} el #{@state_per_order_purchase_approved.created_at.strftime('%d/%m/%Y')}", "#{@second_state} OK"]
    ], :width => 540) do
      row(0).style :align => :center
      row(1).style :align => :center
    end
  end
end