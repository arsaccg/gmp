index2 = 1
total = "#{pdf.page_count}"
bounding_box [bounds.right - 100, bounds.bottom + 520], :width  => 200 do
  text "Página #{index2}", :size => 9
  text @now, :size => 9
end
repeat :all do
  bounding_box [bounds.left, bounds.bottom + 520], :width  => 770 do
    text @company.name, :size => 7.5
    text @cost_center, :size => 7.5
  end
  bounding_box [bounds.right - 650, bounds.bottom + 500], :width  => 500 do
    text "Ingreso - #{@input.warehouse.name}", :align => :center, :style => :bold
  end
  move_down 30

  table([ ["PROVEEDOR: ", "#{@responsable}", "N° DE DOCUMENTO: ", "#{@input.series.to_s} - #{@input.document}"] ], :width => 770, :cell_style => {:height => 18}, :column_widths => [150,350,150,120]) do
    style(columns(0..3), :size => 9)
    columns(0).font_style = :bold
    columns(2).font_style = :bold
  end
  table([ ["ORDEN DE COMPRA", "#{@orders}", " TIPO DE DOCUMENTO:", "#{@input.format.name}"] ], :width => 770, :cell_style => {:height => 18}, :column_widths => [150,350,150,120]) do
    style(columns(0..3), :size => 9)
    columns(0).font_style = :bold
    columns(2).font_style = :bold
  end
  table([ ["GLOSA:", "#{@input.description}", " FECHA DE DOCUMENTO:", "#{@input.issue_date.strftime('%d/%m/%Y')}"] ], :width => 770, :cell_style => {:height => 18}, :column_widths => [150,350,150,120]) do
    style(columns(0..3), :size => 9)
    columns(0).font_style = :bold
    columns(2).font_style = :bold
  end  


  table([ ["CÓDIGO", "DESCRIPCIÓN","UND","CANTIDAD"] ], :width => 770, :column_widths => [150,320,150,150]) do
        style(columns(0..7), :align => :center)
        style(columns(0..7), :size => 9)
      end
end
move_down 3
index=1
@input_detail.each do |data|
  if(@input_detail.first == data)
  stroke_horizontal_rule
  end
  pad(1) {
    table([ ["#{data.article.code}", "#{data.article.name}", "#{data.article.unit_of_measurement.symbol}", "#{data.amount}"] ], :width => 770, :cell_style => {:border_color=> "ffffff"}, :column_widths => [150,370,130,120]) do
        columns(0).font_style = :bold
      style(columns(0..5), :size => 9)
    end
    move_down 4
  }
  stroke_horizontal_rule
  move_down 3
  index += 1
  if cursor()<100
    start_new_page
    total = "#{pdf.page_count}"
    index2 += 1
    bounding_box [bounds.right - 100, bounds.bottom + 520], :width  => 200 do
      text "Página #{index2}", :size => 9
    end
    move_down 152
  end
end

move_down 40

repeat :all do
  bounding_box [bounds.right - 63, bounds.bottom + 520], :width  => 200 do
    text "de #{total}", :size => 9
  end
end

bounding_box [bounds.left, bounds.bottom + 82], :width  => bounds.width do
  pad(1) {
    table([ ["____________________________","____________________________","____________________________"] ], :width => 770, :cell_style => {:border_color=> "ffffff"}, :column_widths => [256.67,256.67,256.66]) do
        columns(0).font_style = :bold
      style(columns(0..2), :size => 9)
      style(columns(0..2), :align => :center)
    end
    table([ ["DIGITADO","APROBADO","","RECIBIDO POR:"] ], :width => 770, :cell_style => {:border_color=> "ffffff"}, :column_widths => [260,260,50,200]) do
        columns(0..3).font_style = :bold
      style(columns(0..3), :size => 9)
      style(columns(0..1), :align => :center)
    end
    table([ ["","","","D.N.I.:"] ], :width => 770, :cell_style => {:border_color=> "ffffff"}, :column_widths => [260,260,50,200]) do
      columns(0..3).font_style = :bold
      style(columns(0..3), :size => 9)
    end    
    move_down 4
  }
end
