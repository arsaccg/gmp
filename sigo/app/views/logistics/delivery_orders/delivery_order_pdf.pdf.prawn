repeat :all do
  bounding_box [bounds.left, bounds.bottom + 720], :width  => 100 do
    image_tag @company.avatar.path, :fit => [100, 50]
  end
  bounding_box [bounds.right - 530, bounds.bottom + 700], :width  => 500 do
    text "ORDEN DE SUMINISTRO - #{@deliveryOrder.id.to_s.rjust(5, '0')}", :align => :center, :style => :bold
  end
  move_down 10

  table([ ["CENTRO DE COSTO", "#{@deliveryOrder.cost_center.name}"], ["EMITIDO POR", "#{@deliveryOrder.user.first_name + ' ' + @deliveryOrder.user.last_name}", "FECHA EMISIÓN", "#{@deliveryOrder.date_of_issue.strftime("%d/%m/%Y")}"], ["ESTADO", "#{translate_delivery_order_state(@deliveryOrder.state)}", "FECHA A ATENDER", "#{@deliveryOrder.scheduled.strftime("%d/%m/%Y")}"] ], :width => 540, :cell_style => {:height => 18}, :column_widths => [150]) do
        style(columns(0..3), :size => 9)
        columns(0).font_style = :bold
        columns(2).font_style = :bold
      end

  move_down 5

  table([ ["ITEM", "CÓDIGO", "DESCRIPCIÓN","At.","Sector","FASE", "U.M", "CANTIDAD"] ], :width => 540, :column_widths => [33,55,227,40,40,40,35,70]) do
        style(columns(0..1), :align => :center)
        style(columns(3..7), :align => :center)
        style(columns(0..7), :size => 9)
      end
end
move_down 3
index=1
@deliveryOrderDetails.each do |data|
  stroke_horizontal_rule
  pad(1) {
    table([ ["#{index}", "#{data.article.code}", "#{data.article.name}", "#{data.center_of_attention.abbreviation}", "#{data.sector.code}", "#{data.phase.code}", "#{data.unit_of_measurement.symbol}", "#{data.amount}"] ], :width => 540, :cell_style => {:border_color=> "ffffff"}, :column_widths => [33,60,222,40,40,40,35,70]) do
        style(columns(0..1), :align => :center)
        style(columns(3..7), :align => :center)
      style(columns(0..7), :size => 9)
    end
    move_down 4
    text "#{data.description}", :size => 9
  }
  stroke_horizontal_rule
  move_down 3
  index += 1
  index += 1
  if cursor()<100
    start_new_page
    move_down 152
  end
end

move_down 40

text "Glosa", :style => :bold
text "#{@deliveryOrder.description}"

bounding_box [bounds.left, bounds.bottom + 50], :width  => bounds.width do
  table([ 
  ["#{@state_per_order_details_approved.user.first_name + ' ' + @state_per_order_details_approved.user.last_name + ' ' + @state_per_order_details_approved.user.surname }", "#{@state_per_order_details_revised.user.first_name + ' ' + @state_per_order_details_revised.user.last_name + ' ' + @state_per_order_details_revised.user.surname }"], ["#{@first_state} el #{@state_per_order_details_approved.created_at.strftime('%d/%m/%Y')}", "#{@second_state} OK"]
  ], :width => 540) do
    row(0).style :align => :center
    row(1).style :align => :center
    columns(0..1).font_style = :bold
  end
end