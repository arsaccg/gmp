index2 = 1
total = "#{pdf.page_count}"
bounding_box [bounds.right - 100, bounds.bottom + 520], :width  => 200 do
  text "Página #{index2}", :size => 9
end
repeat :all do
  bounding_box [bounds.left, bounds.bottom + 520], :width  => 100 do
    image_tag @company.avatar.path, :fit => [100, 50]
  end
  bounding_box [bounds.right - 650, bounds.bottom + 500], :width  => 500 do
    text "ORDEN DE COMPRA - N° #{@cc.code.to_s}-#{@purchaseOrder.id.to_s.rjust(3, '0')}", :align => :center, :style => :bold
  end
  move_down 10

  table([ ["PROVEEDOR", "#{@purchaseOrder.entity.ruc} - #{@purchaseOrder.entity.name}"] ], :width => 770, :cell_style => {:height => 18}, :column_widths => [140]) do
        style(columns(0..1), :size => 9)
        columns(0).font_style = :bold
      end

  table([ ["CENTRO DE COSTO", "#{@purchaseOrder.cost_center.name}"] ], :width => 770, :cell_style => {:height => 18}, :column_widths => [140]) do
        style(columns(0..1), :size => 9)
        columns(0).font_style = :bold
      end

  table([ ["FORMA DE PAGO", "#{@purchaseOrder.method_of_payment.name}", "O/Suministro", "#{@deliveryOrders.map(&:inspect).join(', ')}", "FECHA EMISIÓN", "#{@purchaseOrder.date_of_issue.strftime("%d/%m/%Y")}"] ], :width => 770, :cell_style => {:height => 18}, :column_widths => [140]) do
        style(columns(0..5), :size => 9)
        columns(0).font_style = :bold
        columns(2).font_style = :bold
        columns(4).font_style = :bold
      end

  if ((@purchaseOrder.money.name.include? "Sol") || (@purchaseOrder.money.name.include? "sol"))
  table([ ["ESTADO", "#{translate_purchase_order_state(@purchaseOrder.state)}", "FECHA A ATENDER", "#{@purchaseOrder.delivery_date.strftime("%d/%m/%Y")}"] ], :width => 770, :cell_style => {:height => 18}, :column_widths => [140]) do
        style(columns(0..3), :size => 9)
        columns(0).font_style = :bold
        columns(2).font_style = :bold
      end
  else
  table([ ["ESTADO", "#{translate_purchase_order_state(@purchaseOrder.state)}", "FECHA A ATENDER", "#{@purchaseOrder.delivery_date.strftime("%d/%m/%Y")}","TIPO DE CAMBIO", "#{@purchaseOrder.money.name} : #{@purchaseOrder.exchange_of_rate}"] ], :width => 770, :cell_style => {:height => 18}, :column_widths => [140]) do
        style(columns(0..3), :size => 9)
        columns(0).font_style = :bold
        columns(2).font_style = :bold
        columns(4).font_style = :bold
      end
  end

  table([ ["ITEM", " CÓDIGO", "DESCRIPCIÓN","At.","Sector","FASE", "U.M", "CANTIDAD", "PRECIO UNITARIO", "% Dscto", "SUBTOTAL"] ], :width => 770, :cell_style => {:height => 18}, :column_widths => [35,60,275,35,40,40,30,60,90,50,55]) do
        style(columns(0..10), :align => :center)
        style(columns(0..10), :size => 9)
      end
end
move_down 3
index=1
@purchaseOrderDetails.each do |data|
  if(@purchaseOrderDetails.first==data)
  stroke_horizontal_rule
  end
  pad(1) {
    table([ ["#{index}", "#{data.delivery_order_detail.article.code}", "#{data.delivery_order_detail.article.name}", "#{data.delivery_order_detail.center_of_attention.abbreviation}", "#{data.delivery_order_detail.sector.code}", "#{data.delivery_order_detail.phase.code}", "#{data.delivery_order_detail.unit_of_measurement.symbol}", "#{sprintf("%.2f", data.amount)}", "#{number_to_currency(data.unit_price, unit: @purchaseOrder.money.symbol, precision: 2)}", ".00", "#{number_to_currency(data.amount*data.unit_price, unit: @purchaseOrder.money.symbol, precision: 2)}"] ], :width => 770, :cell_style => {:border_color=> "ffffff"}, :column_widths => [35,60,275,35,40,40,30,60,90,50,55]) do
      columns(0).font_style = :bold
      style(columns(0..1), :align => :center)
      style(columns(3..7), :align => :center)
      style(columns(8..10), :align => :right)
      style(columns(0..10), :size => 7.5)
    end
    move_down 2
    text "#{data.description}", :size => 7.5
  }
  stroke_horizontal_rule
  move_down 2
  index += 1
  if cursor()<100
    start_new_page
    total = "#{pdf.page_count}"
    index2 += 1
    bounding_box [bounds.right - 80, bounds.bottom + 520], :width  => 200 do
      text "Página #{index2}", :size => 7
    end
    move_down 152
  end
end

move_down 10

text "Glosa", :style => :bold, :size => 9
text "#{@purchaseOrder.description}", :size => 9
repeat :all do
  bounding_box [bounds.right - 63, bounds.bottom + 520], :width  => 200 do
    text "de #{total}", :size => 9
  end
end
bounding_box [bounds.left, bounds.bottom + 82], :width  => bounds.width do
  text "#{@total_neto.to_i.to_words.upcase} Y #{number_with_precision (@total_neto-@total_neto.to_i)*100, :precision => 0}/100 #{@purchaseOrder.money.name.upcase}", :size => 8,:style => :bold
end
bounding_box [bounds.left, bounds.bottom + 70], :width  => bounds.width do
  table([ 
    ["", "Condiciones:
    1. Facturar adjuntando O/C y guias recepcionadas
    2. Indicar procedencia, marca y lote de producción en casos aplicables
    3. Adjuntar certificado de calidad, en casos aplicables", ""]
  ], :width => 550, :column_widths => [70, 410, 70]) do
      style(columns(0..2), :size => 8)
    end
end

bounding_box [bounds.right - 200, bounds.bottom + 80], :width  => bounds.width do
  table([ 
    ["TOTAL","#{number_to_currency(@total, unit: @purchaseOrder.money.symbol, precision: 2)}"],
    ["IGV #{number_to_percentage(@igv*100, precision: 0)}","#{number_to_currency(@igv_neto, unit: @purchaseOrder.money.symbol, precision: 2)}"]
  ], :width => 190, :cell_style => {:border_color=> "ffffff", :height => 21}, :column_widths => [100, 90]) do
      style(columns(0..1), :size => 10, :align => :right)
      columns(0..1).font_style = :bold
    end
  table([ 
    ["TOTAL NETO "," #{number_to_currency(@total_neto, unit: @purchaseOrder.money.symbol, precision: 2)}"]
  ], :width => 190, :cell_style => {:border_bottom_color=> "ffffff",:border_left_color=> "ffffff",:border_right_color=> "ffffff", :height => 21}, :column_widths => [100, 90]) do
      style(columns(0..1), :size => 10, :align => :right)
      columns(0..1).font_style = :bold
    end     
end