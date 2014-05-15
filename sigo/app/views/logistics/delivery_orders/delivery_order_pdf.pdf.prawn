text "ORDEN DE SUMINISTRO - #{@deliveryOrder.id.to_s.rjust(5, '0')}", :align => :center

move_down 20

table([ ["CENTRO DE COSTO", "#{@deliveryOrder.cost_center.name}"], ["EMITIDO POR", "#{@deliveryOrder.user.first_name + ' ' + @deliveryOrder.user.last_name}", "FECHA EMISIÓN", "#{@deliveryOrder.date_of_issue.strftime("%d/%m/%Y")}"], ["ESTADO", "#{translate_delivery_order_state(@deliveryOrder.state)}", "FECHA A ATENDER", "#{@deliveryOrder.scheduled.strftime("%d/%m/%Y")}"] ], :width => 540, :column_widths => [150])

move_down 20

table([ ["ITEM", "CÓDIGO    ", "DESCRIPCIÓN                                      At. Sector FASE", "U.M", "CANTIDAD"] ], :width => 540)

move_down 3

@deliveryOrderDetails.each do |data|
  stroke_horizontal_rule
  pad(5) {
    table([ ["#{data.id}", "#{data.article.code}", "#{data.article.name}", "#{data.center_of_attention.abbreviation}", "#{data.sector.code}", "#{data.phase.code}", "#{data.unit_of_measurement.symbol}", "#{data.amount}"] ], :width => 540, :cell_style => {:border_color=> "ffffff"}, :column_widths => [43,77,200,37,27,47,35,74]) do
      style(columns(7), :align => :right)
    end
    move_down 4
    text "#{data.description}"
  }
  stroke_horizontal_rule
  move_down 3
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
  end
end