text "ORDEN DE SERVICIO - #{@orderOfService.id.to_s.rjust(5, '0')}", :align => :center

move_down 20

table([ ["PROVEEDOR", "#{@orderOfService.entity.ruc} - #{@orderOfService.entity.name}"] ], :width => 770, :column_widths => [140])
table([ ["CENTRO DE COSTO", "#{@orderOfService.cost_center.name}"] ], :width => 770, :column_widths => [140])
table([ ["FORMA DE PAGO", "#{@orderOfService.method_of_payment.name}", "FECHA EMISIÓN", "#{@orderOfService.date_of_issue.strftime("%d/%m/%Y")}"] ], :width => 770, :column_widths => [140])
table([ ["ESTADO", "#{translate_purchase_order_state(@orderOfService.state)}", "FECHA DE SERVICIO", "#{@orderOfService.date_of_service.strftime("%d/%m/%Y")}"] ], :width => 770, :column_widths => [140])

move_down 20

table([ ["ITEM", " CÓDIGO   ", "DESCRIPCIÓN                                     Sector   FASE", "U.M", "CANTIDAD", "PRECIO UNITARIO", "% Dscto", "SUBTOTAL"] ], :width => 770)

move_down 3

@orderServiceDetails.each do |data|
  stroke_horizontal_rule
  pad(5) {
    table([ ["#{data.id}", "#{data.article.code}", "#{data.article.name}", "#{data.sector.code}", "#{data.phase.code}", "#{data.unit_of_measurement.symbol}", "#{sprintf("%.2f", data.amount)}", "#{number_to_currency(data.unit_price, unit: @orderOfService.money.symbol, precision: 2)}", ".00", "#{number_to_currency(data.amount*data.unit_price, unit: @orderOfService.money.symbol, precision: 2)}"] ], :width => 770, :cell_style => {:border_color=> "fffffff"}, :column_widths => [40,80,210,35,50,30,75,120,55,75]) do
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
text "#{@orderOfService.description}"

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
    text "IGV 18%                 #{number_to_currency(@igv_neto, unit: '', precision: 2)}"
    move_down 5
    text "TOTAL NETO #{@orderOfService.money.symbol}     #{number_to_currency(@total_neto, unit: '', precision: 2)}"
  end
end