index2 = 1
total = "#{pdf.page_count}"
bounding_box [bounds.right - 100, bounds.bottom + 720], :width  => 200 do
  text "Página #{index2}", :size => 9
end
repeat :all do
  bounding_box [bounds.left, bounds.bottom + 720], :width  => 200 do
    image @company.avatar.path, :fit => [100, 38] rescue nil
    text @company.name, :size => 9
    text @company.address, :size => 9
    text @company.ruc, :size => 9
  end
  bounding_box [bounds.right - 530, bounds.bottom + 680], :width  => 500 do
    text "ORDEN DE SUMINISTRO - N° #{@cost_center_code + '-' + @deliveryOrder.code.to_s.rjust(5, '0')}", :align => :center, :style => :bold
  end
  move_down 30

  table([ ["CENTRO DE COSTO", "#{@deliveryOrder.cost_center.name}"] ], :width => 540, :cell_style => {:height => 18}, :column_widths => [150]) do
    style(columns(0..1), :size => 9)
    columns(0).font_style = :bold
    columns(2).font_style = :bold
  end
  table([ ["EMITIDO POR", "#{@deliveryOrder.user.first_name + ' ' + @deliveryOrder.user.last_name}", "FECHA EMISIÓN", "#{@deliveryOrder.date_of_issue.strftime("%d/%m/%Y")}"], ["ESTADO", "#{translate_delivery_order_state(@deliveryOrder.state)}", "FECHA A ATENDER", "#{@deliveryOrder.scheduled.strftime("%d/%m/%Y")}"] ], :width => 540, :cell_style => {:height => 18}, :column_widths => [150]) do
        style(columns(0..3), :size => 9)
        columns(0).font_style = :bold
        columns(2).font_style = :bold
      end


  table([ ["ITEM", "CÓDIGO", "DESCRIPCIÓN","At.","Sector","FASE", "U.M", "CANTIDAD"] ], :width => 540, :column_widths => [33,55,227,40,40,40,35,70]) do
        style(columns(0..7), :align => :center)
        style(columns(0..7), :size => 9)
      end
end
move_down 3
index=1
@deliveryOrderDetails.each do |data|
  if(@deliveryOrderDetails.first == data)
  stroke_horizontal_rule
  end
  pad(1) {
    table([ ["#{index}", "#{data.article.code}", "#{data.article.name}", "#{data.center_of_attention.abbreviation}", "#{data.sector.code}", "#{data.phase.code}", "#{data.unit_of_measurement.symbol}", "#{number_to_currency(data.amount.to_f, unit: ' ', precision: 2)}"] ], :width => 540, :cell_style => {:border_color=> "ffffff"}, :column_widths => [33,60,222,40,40,40,35,70]) do
        columns(0).font_style = :bold
        style(columns(0..1), :align => :center)
        style(columns(3..7), :align => :center)
      style(columns(0..7), :size => 7.5)
    end
    move_down 4
    text "#{data.description}", :size => 7.5
  }
  stroke_horizontal_rule
  move_down 3
  index += 1
  if cursor()<100
    start_new_page
    total = "#{pdf.page_count}"
    index2 += 1
    bounding_box [bounds.right - 100, bounds.bottom + 720], :width  => 200 do
      text "Página #{index2}", :size => 9
    end
    move_down 152
  end
end

move_down 40

text "Glosa", :style => :bold, :size =>9
text "#{@deliveryOrder.description}", :size => 9
repeat :all do
  bounding_box [bounds.right - 63, bounds.bottom + 720], :width  => 200 do
    text "de #{total}", :size => 9
  end
end
bounding_box [bounds.left, bounds.bottom + 50], :width  => bounds.width do
  table([ 
  ["#{@state_per_order_details_approved.user.first_name + ' ' + @state_per_order_details_approved.user.last_name + ' ' + @state_per_order_details_approved.user.surname }", "#{@state_per_order_details_revised.user.first_name + ' ' + @state_per_order_details_revised.user.last_name + ' ' + @state_per_order_details_revised.user.surname }"], ["#{@first_state} el #{@state_per_order_details_approved.created_at.strftime('%d/%m/%Y')}", "#{@second_state} OK"]
  ], :width => 540) do
    row(0).style :align => :center
    row(1).style :align => :center
    columns(0..1).font_style = :bold
    columns(0..1).size = 9
  end
end