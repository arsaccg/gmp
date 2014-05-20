text "ORDEN DE COMPRA - #{@purchaseOrder.id.to_s.rjust(5, '0')}", :align => :center, :style => :bold

move_down 20

table([ ["PROVEEDOR", "#{@purchaseOrder.entity.ruc} - #{@purchaseOrder.entity.name}"] ], :width => 770, :column_widths => [140]) do
      style(columns(0), :size => 11)
      columns(0).font_style = :bold
    end

table([ ["CENTRO DE COSTO", "#{@purchaseOrder.cost_center.name}"] ], :width => 770, :column_widths => [140]) do
      style(columns(0), :size => 11)
      columns(0).font_style = :bold
    end

table([ ["FORMA DE PAGO", "#{@purchaseOrder.method_of_payment.name}", "O/Suministro", "#{@deliveryOrders.map(&:inspect).join(', ')}", "FECHA EMISIÓN", "#{@purchaseOrder.date_of_issue.strftime("%d/%m/%Y")}"] ], :width => 770, :column_widths => [140]) do
      style(columns(0), :size => 11)
      columns(0).font_style = :bold
      columns(2).font_style = :bold
      columns(4).font_style = :bold
    end

if ((@purchaseOrder.money.name.include? "Sol") || (@purchaseOrder.money.name.include? "sol"))
table([ ["ESTADO", "#{translate_purchase_order_state(@purchaseOrder.state)}", "FECHA A ATENDER", "#{@purchaseOrder.delivery_date.strftime("%d/%m/%Y")}"] ], :width => 770, :column_widths => [140]) do
      style(columns(0), :size => 11)
      columns(0).font_style = :bold
      columns(2).font_style = :bold
    end
else
table([ ["ESTADO", "#{translate_purchase_order_state(@purchaseOrder.state)}", "FECHA A ATENDER", "#{@purchaseOrder.delivery_date.strftime("%d/%m/%Y")}","TIPO DE CAMBIO", "#{@purchaseOrder.money.name} : #{@purchaseOrder.exchange_of_rate}"] ], :width => 770, :column_widths => [140]) do
      style(columns(0), :size => 11)
      columns(0).font_style = :bold
      columns(2).font_style = :bold
      columns(4).font_style = :bold
    end
end

move_down 20

table([ ["ITEM", " CÓDIGO   ", "DESCRIPCIÓN                                   At.  Sector   FASE", "U.M", "CANTIDAD", "PRECIO UNITARIO", "% Dscto", "SUBTOTAL"] ], :width => 770)

move_down 3
index=1
@purchaseOrderDetails.each do |data|
  stroke_horizontal_rule
  pad(5) {
    table([ ["#{index}", "#{data.delivery_order_detail.article.code}", "#{data.delivery_order_detail.article.name}", "#{data.delivery_order_detail.center_of_attention.abbreviation}", "#{data.delivery_order_detail.sector.code}", "#{data.delivery_order_detail.phase.code}", "#{data.delivery_order_detail.unit_of_measurement.symbol}", "#{sprintf("%.2f", data.amount)}", "#{number_to_currency(data.unit_price, unit: @purchaseOrder.money.symbol, precision: 2)}", ".00", "#{number_to_currency(data.amount*data.unit_price, unit: @purchaseOrder.money.symbol, precision: 2)}"] ], :width => 770, :cell_style => {:border_color=> "ffffff"}, :column_widths => [35,80,195,35,35,45,30,70,120,50,75]) do
      style(columns(6..10), :align => :right)
      style(columns(0..10), :size => 11)
    end
    move_down 4
    text "#{data.description}"
  }
  stroke_horizontal_rule
  move_down 3
  index += 1
  if index%6==1
    start_new_page
    move_down 150
  end
end

move_down 10

text "Glosa", :style => :bold
text "#{@purchaseOrder.description}"
bounding_box [bounds.left, bounds.bottom + 82], :width  => bounds.width do
  text "#{@total_neto.to_i.to_words.capitalize} y #{number_with_precision (@total_neto-@total_neto.to_i)*100, :precision => 0}/100 #{@purchaseOrder.money.name}"
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
    ["TOTAL NETO #{@purchaseOrder.money.symbol}"," #{number_to_currency(@total_neto, unit: '', precision: 2)}"]
  ], :width => 220, :cell_style => {:border_color=> "ffffff"}, :column_widths => [130, 90]) do
      style(columns(1), :align => :right)
      style(columns(0..1), :size => 12)
      columns(0..1).font_style = :bold
    end
end