text "ORDEN DE SERVICIO - #{@orderOfService.id.to_s.rjust(5, '0')}", :align => :center, :style => :bold
image "/home/gguzman/sitios_web/gmp/sigo/app/assets/images/logo.png", :width => 100, :height => 50

move_down 20

table([ ["PROVEEDOR", "#{@orderOfService.entity.ruc} - #{@orderOfService.entity.name}"] ], :width => 770, :column_widths => [140]) do
      style(columns(0..1), :size => 9)
      columns(0).font_style = :bold
    end
table([ ["CENTRO DE COSTO", "#{@orderOfService.cost_center.name}"] ], :width => 770, :column_widths => [140]) do
      style(columns(0..1), :size => 9)
      columns(0).font_style = :bold
    end
table([ 
    ["FORMA DE PAGO", "#{@orderOfService.method_of_payment.name}", "FECHA EMISIÓN", "#{@orderOfService.date_of_issue.strftime("%d/%m/%Y")}"],
    ["ESTADO", "#{translate_purchase_order_state(@orderOfService.state)}", "FECHA DE SERVICIO", "#{@orderOfService.date_of_service.strftime("%d/%m/%Y")}"]
  ], :width => 770, :column_widths => [140]) do
      style(columns(0..3), :size => 9)
      columns(0).font_style = :bold
      columns(2).font_style = :bold
    end

move_down 20

table([ ["ITEM", "CÓDIGO", "DESCRIPCIÓN","Sector","FASE", "U.M", "CANTIDAD", "PRECIO UNITARIO", "% Dscto", "SUBTOTAL"] ], :width => 770, :column_widths => [40,80,190,55,50,30,75,120,55,75]) do
      style(columns(3..8), :align => :center)
      style(columns(9), :align => :right)
      style(columns(0..9), :size => 9)
      columns(0).font_style = :bold
      columns(1).font_style = :bold
      columns(2).font_style = :bold
      columns(3).font_style = :bold
      columns(4).font_style = :bold
      columns(5).font_style = :bold
      columns(6).font_style = :bold
      columns(7).font_style = :bold
      columns(8).font_style = :bold
      columns(9).font_style = :bold
    end

move_down 3

@orderServiceDetails.each do |data|
  stroke_horizontal_rule
  pad(5) {
    table([ ["#{data.id}", "#{data.article.code}", "#{data.article.name}", "#{data.sector.code}", "#{data.phase.code}", "#{data.unit_of_measurement.symbol}", "#{sprintf("%.2f", data.amount)}", "#{number_to_currency(data.unit_price, unit: @orderOfService.money.symbol, precision: 2)}", ".00", "#{number_to_currency(data.amount*data.unit_price, unit: @orderOfService.money.symbol, precision: 2)}"] ], :width => 770, :cell_style => {:border_color=> "fffffff"}, :column_widths => [40,80,190,55,50,30,75,120,55,75]) do
      style(columns(3..8), :align => :center)
      style(columns(9), :align => :right)
      style(columns(0..9), :size => 9)
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
bounding_box [bounds.left, bounds.bottom + 82], :width  => bounds.width do
  text "#{@total_neto.to_i.to_words.capitalize} y #{number_with_precision (@total_neto-@total_neto.to_i)*100, :precision => 0}/100 #{@orderOfService.money.name}"
end
bounding_box [bounds.left, bounds.bottom + 70], :width  => bounds.width do
table([ 
  ["", "Condiciones:
  1. Facturar adjuntando O/C y guias recepcionadas
  2. Indicar procedencia, marca y lote de producción en casos aplicables
  3. Adjuntar certificado de calidad, en casos aplicables", ""]
], :width => 550, :column_widths => [70, 410, 70]) do
      style(columns(0..2), :size => 10)
    end
end
bounding_box [bounds.right - 200, bounds.bottom + 80], :width  => bounds.width do
  table([ 
    ["TOTAL","#{number_to_currency(@total, unit: '', precision: 2)}"],
    ["IGV #{number_to_percentage(@igv*100, precision: 0)}","#{number_to_currency(@igv_neto, unit: '', precision: 2)}"],
    ["TOTAL NETO #{@orderOfService.money.symbol}","#{number_to_currency(@total_neto, unit: '', precision: 2)}"]
  ], :width => 220, :cell_style => {:border_color=> "ffffff"}, :column_widths => [130, 90]) do
      style(columns(1), :align => :right)
      style(columns(0..1), :size => 12)
      columns(0..1).font_style = :bold
    end
end