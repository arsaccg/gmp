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
    text "Salida - #{@output.warehouse.name}", :align => :center, :style => :bold
  end
  move_down 30

  table([ ["RESPONSABLE: ", "#{@responsable}", "N° DE DOCUMENTO: ", "#{@output.series.to_s} - #{@output.document}"] ], :width => 770, :cell_style => {:height => 18}, :column_widths => [150,350,150,120]) do
    style(columns(0..3), :size => 9)
    columns(0).font_style = :bold
    columns(2).font_style = :bold
  end
  table([ ["GRUPO DE TRABAJO", "#{@output.working_group.name}", " TIPO DE DOCUMENTO:", "#{@output.format.name}"] ], :width => 770, :cell_style => {:height => 18}, :column_widths => [150,350,150,120]) do
    style(columns(0..3), :size => 9)
    columns(0).font_style = :bold
    columns(2).font_style = :bold
  end
  table([ ["GLOSA:", "#{@output.description}", " FECHA DE DOCUMENTO:", "#{@output.issue_date.strftime('%d/%m/%Y')}"] ], :width => 770, :cell_style => {:height => 18}, :column_widths => [150,350,150,120]) do
    style(columns(0..3), :size => 9)
    columns(0).font_style = :bold
    columns(2).font_style = :bold
  end  


  table([ ["CÓDIGO", "DESCRIPCIÓN","UND","CANTIDAD","SECTOR", "FASE - SUBFASE"] ], :width => 770, :column_widths => [80,300,40,100,125,125]) do
        style(columns(0..7), :align => :center)
        style(columns(0..7), :size => 9)
      end
end
move_down 3
index=1
@output_detail.each do |data|
  if(@output_detail.first == data)
  stroke_horizontal_rule
  end
  pad(1) {
    table([ ["#{data.article.code}", "#{data.article.name}", "#{data.article.unit_of_measurement.symbol}", "#{data.amount}","#{data.sector.code}", "#{data.phase.code} - #{data.phase.name} "] ], :width => 770, :cell_style => {:border_color=> "ffffff"}, :column_widths => [80,300,40,100,125,125]) do
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
    table([ ["","#{@user}","","","D.N.I.:"] ], :width => 770, :cell_style => {:border_color=> "ffffff"}, :column_widths => [60,200,260,50,200]) do
      columns(0..4).font_style = :bold
      style(columns(0..4), :size => 9)
    end       
    move_down 4
  }
end