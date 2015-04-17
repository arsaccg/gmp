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
    text "ORDEN DE SERVICIO - N° #{@cc.code.to_s}-#{@orderOfService.id.to_s.rjust(3, '0')}", :align => :center, :style => :bold
  end
  move_down 10

  table([ ["PROVEEDOR", "#{@orderOfService.entity.ruc} - #{@orderOfService.entity.name}"] ], :width => 770, :cell_style => {:height => 18}, :column_widths => [140]) do
        style(columns(0..1), :size => 9)
        columns(0).font_style = :bold
      end
  table([ ["CENTRO DE COSTO", "#{@orderOfService.cost_center.name}"] ], :width => 770, :cell_style => {:height => 18}, :column_widths => [140]) do
        style(columns(0..1), :size => 9)
        columns(0).font_style = :bold
      end
  table([ 
      ["FORMA DE PAGO", "#{@orderOfService.method_of_payment.name}", "FECHA EMISIÓN", "#{@orderOfService.date_of_issue.strftime("%d/%m/%Y")}"],
      ["ESTADO", "#{translate_purchase_order_state(@orderOfService.state)}", "FECHA DE SERVICIO", "#{@orderOfService.date_of_service.strftime("%d/%m/%Y")}"]
    ], :width => 770, :cell_style => {:height => 18}, :column_widths => [140]) do
        style(columns(0..3), :size => 9)
        columns(0).font_style = :bold
        columns(2).font_style = :bold
      end

  table([ ["ITEM", "CÓDIGO", "DESCRIPCIÓN","G. T.","SECTOR","FASE","U.M", "CANTIDAD", "PRECIO UNI.", "% Dscto", "SUBTOTAL"] ], :width => 770, :cell_style => {:height => 18}, :column_widths => [35,70,230,80,40,40,30,65,50,55,75]) do
        style(columns(0..10), :align => :center)
        style(columns(0..10), :size => 9)
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
        columns(10).font_style = :bold
      end
end
move_down 3
index=1
@orderServiceDetails.each do |data|
  if(@orderServiceDetails.first==data)
  stroke_horizontal_rule
  end
  if(data.working_group_id==nil)
  wg="-"
  else
  wg = data.working_group.name
  end
  pad(1) {
    table([ ["#{index}", "#{data.article.code}", "#{data.article.name}", "#{wg}", "#{data.sector.code}", "#{data.phase.code rescue '-'}", "#{data.unit_of_measurement.symbol}", "#{number_to_currency(data.amount.to_f, unit: ' ', precision: 2)}", "#{number_to_currency(data.unit_price, unit: ' ', precision: 2)}", ".00", "#{number_to_currency(data.amount.to_f*data.unit_price.to_f, unit: ' ', precision: 2)}"] ], :width => 770, :cell_style => {:border_color=> "fffffff"}, :column_widths => [35,70,230,80,40,40,30,65,50,55,75]) do
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
  if cursor()<120
    start_new_page
    total = "#{pdf.page_count}"
    index2 += 1
    bounding_box [bounds.right - 100, bounds.bottom + 520], :width  => 200 do
      text "Página #{index2}", :size => 9
    end
    move_down 140
    stroke_horizontal_rule
  end
end

move_down 10
text "Glosa", :style => :bold, :size => 9
text "#{@orderOfService.description}", :size => 9
repeat :all do
  bounding_box [bounds.right - 63, bounds.bottom + 520], :width  => 200 do
    text "de #{total}", :size => 9
  end
end
bounding_box [bounds.left, bounds.bottom + 72], :width  => bounds.width do
  text "#{@total_neto.to_i.to_words.upcase} Y #{number_with_precision (@total_neto-@total_neto.to_i)*100, :precision => 0}/100 #{@orderOfService.money.name.upcase}", :size => 9,:style => :bold
end
bounding_box [bounds.left, bounds.bottom + 60], :width  => bounds.width do
table([ 
  ["", "Condiciones:
  1. Facturar adjuntando O/C y guias recepcionadas
  2. Indicar procedencia, marca y lote de producción en casos aplicables
  3. Adjuntar certificado de calidad, en casos aplicables", ""]
], :width => 550, :column_widths => [70, 410, 70]) do
      style(columns(0..2), :size => 8)
    end
end
bounding_box [bounds.right - 200, bounds.bottom + 70], :width  => bounds.width do
  table([ 
    ["TOTAL","#{number_to_currency(@total, unit: '', precision: 2)}"],
    ["IGV #{number_to_percentage(@igv*100, precision: 0)}","#{number_to_currency(@igv_neto, unit: '', precision: 2)}"]
  ], :width => 190, :cell_style => {:border_color=> "ffffff", :height => 21}, :column_widths => [100, 90]) do
      style(columns(0..1), :size => 10, :align => :right)
      columns(0..1).font_style = :bold
    end
  table([ 
    ["TOTAL NETO #{@orderOfService.money.symbol}","#{number_to_currency(@total_neto, unit: '', precision: 2)}"]
  ], :width => 190, :cell_style => {:border_bottom_color=> "ffffff",:border_left_color=> "ffffff",:border_right_color=> "ffffff", :height => 21}, :column_widths => [100, 90]) do
      style(columns(0..1), :size => 10, :align => :right)
      columns(0..1).font_style = :bold
    end    
end