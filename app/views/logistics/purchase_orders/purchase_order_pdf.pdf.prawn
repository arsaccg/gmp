text "ORDEN DE COMPRA - #{@purchaseOrder.id.to_s.rjust(5, '0')}", :align => :center

move_down 20

table([ ["PROVEEDOR", "#{@purchaseOrder.entity.ruc} - #{@purchaseOrder.entity.name}"] ], :width => 770, :column_widths => [140])
table([ ["CENTRO DE COSTO", "#{@purchaseOrder.cost_center.name}"] ], :width => 770, :column_widths => [140])
table([ ["FORMA DE PAGO", "#{@purchaseOrder.method_of_payment.name}", "O/Suministro", "#{@deliveryOrders.map(&:inspect).join(', ')}", "FECHA EMISIÓN", "#{@purchaseOrder.date_of_issue.strftime("%d/%m/%Y")}"] ], :width => 770, :column_widths => [140])
table([ ["ESTADO", "#{translate_purchase_order_state(@purchaseOrder.state)}", "FECHA A ATENDER", "#{@purchaseOrder.delivery_date.strftime("%d/%m/%Y")}"] ], :width => 770, :column_widths => [140])

move_down 20

table([ ["ITEM", " CÓDIGO   ", "DESCRIPCIÓN                                   At.  Sector   FASE", "U.M", "CANTIDAD", "PRECIO UNITARIO", "% Dscto", "SUBTOTAL"] ], :width => 770)

move_down 3

@purchaseOrderDetails.each do |data|
  stroke_horizontal_rule
  pad(5) {
    table([ ["#{data.id}", "#{data.delivery_order_detail.article.code}", "#{data.delivery_order_detail.article.description}", "#{data.delivery_order_detail.center_of_attention.abbreviation}", "#{data.delivery_order_detail.sector.code}", "#{data.delivery_order_detail.phase.code}", "#{data.delivery_order_detail.unit_of_measurement.symbol}", "#{sprintf("%.2f", data.delivery_order_detail.amount)}", "#{number_to_currency(data.unit_price, unit: @purchaseOrder.money.symbol, precision: 2)}", ".00", "#{number_to_currency(data.delivery_order_detail.amount*data.unit_price, unit: @purchaseOrder.money.symbol, precision: 2)}"] ], :width => 770, :cell_style => {:border_color=> "ffffff"}, :column_widths => [35,80,195,35,35,45,30,70,120,50,75]) do
      style(columns(7..11), :align => :right)
    end
    move_down 4
    text "#{data.description}"
  }
  stroke_horizontal_rule
  move_down 3
end

move_down 10

text "Glosa", :style => :bold
text "#{@purchaseOrder.description}"

repeat :all do
   bounding_box [bounds.left, bounds.bottom + 53], :width  => bounds.width do
    table([ 
      ["", "Condiciones:
      1. Facturar adjuntando O/C y guias recepcionadas
      2. Indicar procedencia, marca y lote de producción en casos aplicables
      3. Adjuntar certificado de calidad, en casos aplicables", ""]
    ], :width => 600, :column_widths => [90, 420, 90])
  end

  bounding_box [bounds.right - 150, bounds.bottom + 53], :width  => bounds.width do
    text "TOTAL                  #{number_to_currency(@total, unit: '', precision: 2)}"
    move_down 5
    text "IGV 18%                 #{number_to_currency(@igv, unit: '', precision: 2)}"
    move_down 5
    text "TOTAL NETO #{@purchaseOrder.money.symbol}     #{number_to_currency(@total_neto, unit: '', precision: 2)}"
  end
end