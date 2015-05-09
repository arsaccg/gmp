index2 = 1
total = "#{pdf.page_count}"
bounding_box [bounds.right - 100, bounds.bottom + 780], :width  => 200 do
  text "Página #{index2}", :size => 9
  text @now, :size => 9
end
repeat :all do
  bounding_box [bounds.left, bounds.bottom + 780], :width  => 200 do
    text @company.name, :size => 7.5
    text @cost_center, :size => 7.5
  end
  bounding_box [bounds.right - 500, bounds.bottom + 740], :width  => 500 do
    text "SALIDAS - #{@output.warehouse.name}", :align => :center, :style => :bold
  end
  move_down 10

  table([ ["RESPONSABLE: ", "#{@responsable[0..50]}", "N° DE DOCUMENTO: ", "#{@output.series.to_s} - #{@output.document}"] ], :width => 530, :cell_style => {:border_color=> "ffffff", :height => "16px"}, :column_widths => [65,243,100,122]) do
    style(columns(0..3), :size => 7)
    style(columns(0..3), :border => "white")
    columns(0).font_style = :bold
    columns(2).font_style = :bold
  end
  table([ ["G. DE TRABAJO", "#{@output.working_group.name[0..50]}", " TIPO DE DOCUMENTO:", "#{@output.format.name}"] ], :width => 530, :cell_style => {:border_color=> "ffffff", :height => "16px"}, :column_widths => [65,243,100,122]) do
    style(columns(0..3), :size => 7)
    columns(0).font_style = :bold
    columns(2).font_style = :bold
  end
  table([ ["GLOSA:", "#{@output.description[0..50]}", " FECHA DE DOCUMENTO:", "#{@output.issue_date.strftime('%d/%m/%Y')}"] ], :width => 530, :cell_style => {:border_color=> "ffffff", :height => "16px"}, :column_widths => [65,243,100,122]) do
    style(columns(0..3), :size => 7)
    columns(0).font_style = :bold
    columns(2).font_style = :bold
  end  
  move_down 10

  table([ ["Código", "Descripción","Und","Cant.","Sector", "Fase - Subfase"] ], :width => 530, :column_widths => [55,250,25,57,35,108],:cell_style => {:height => "17px"}) do
        style(columns(0..7), :align => :center)
        style(columns(0..7), :size => 8)
        columns(0..7).font_style = :bold
      end
end
move_down 3
index=1
@output_detail.each do |data|
  if(@output_detail.first == data)
  end
  pad(1) {
    table([ ["#{data.article.code}", "#{data.article.name}", "#{data.article.unit_of_measurement.symbol}", "#{data.amount}","#{data.sector.code}", "#{data.phase.code} - #{data.phase.name[0..12]} "] ], :width => 530, :cell_style => {:border_color=> "ffffff"}, :column_widths =>[55,250,25,57,35,108]) do
      columns(0).font_style = :bold
      columns(2).text_align = :center
      style(columns(0..5), :size => 8)
    end
    move_down 4
  }
  move_down 3
  index += 1
  if cursor()<100
    start_new_page
    total = "#{pdf.page_count}"
    index2 += 1
    bounding_box [bounds.right - 100, bounds.bottom + 780], :width  => 200 do
      text "Página #{index2}", :size => 9
    end
    move_down 152
  end
end

move_down 40

repeat :all do
  bounding_box [bounds.right - 63, bounds.bottom + 780], :width  => 200 do
    text "de #{total}", :size => 9
  end
end
bounding_box [bounds.left, bounds.bottom + 82], :width  => bounds.width do
  pad(1) {
    table([ ["____________________________","____________________________","____________________________"] ], :width => 500, :cell_style => {:border_color=> "ffffff"}, :column_widths => [165,165,170]) do
        columns(0).font_style = :bold
      style(columns(0..2), :size => 9)
      style(columns(0..2), :align => :center)
    end
    table([ ["DIGITADO","APROBADO","","RECIBIDO POR:"] ], :width => 500, :cell_style => {:border_color=> "ffffff"}, :column_widths => [170,170,10,150]) do
        columns(0..3).font_style = :bold
      style(columns(0..3), :size => 9)
      style(columns(0..1), :align => :center)
    end
    table([ ["","#{@user}","","","D.N.I.:"] ], :width => 500, :cell_style => {:border_color=> "ffffff"}, :column_widths => [10,160,150,30,150]) do
      columns(0..4).font_style = :bold
      style(columns(0..4), :size => 9)
    end       
    move_down 4
  }
end