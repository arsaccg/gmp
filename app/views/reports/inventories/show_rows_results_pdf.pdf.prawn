font "Helvetica"

case @kardex_type
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # Kardex Yearly
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  when "1"
	
	repeat :all do
	  font_size 12

	  text "Kárdex Anual", :align => :center

	  font_size 8
	  move_down 3

	  # header
	  table([ [{content:"Almacén", rowspan: 2}, {content:"Año", rowspan: 2}, {content:"Código", rowspan: 2}, {content:"Descripción", rowspan: 2}, {content:"Unidad", rowspan: 2},  
		{content: "Ingreso", colspan: 3}, {content: "Salida", colspan: 3}],
		["Cantidad", "C/Unitario", "Costo", "Cantidad", "C/Unitario", "Costo"] ], :width => 770, :column_widths => [80,30,60,230,50,50,50,60,50,50,60])  do
		  style(columns(5..10), :align => :center)
		end

	  move_down 3
	end

	item = 0
	@reportRows.each do |x|
	  # Page Bring
	  item += 1
	  if item == @rows_per_page
	    start_new_page
	    move_down 60
	    item = 1
	  end

	  # Data
	  case x[0][0]
	    when 1
		  pad(1) {
		    table([ ["#{x[0][2]}", "#{x[0][3]}", "#{x[0][9]}", "#{x[0][10]}", "#{x[0][11]}", "#{x[1]}", "#{number_with_precision(1, precision: 2)}", "#{number_with_precision(x[1], precision: 2, delimiter: ',')}", "", "", ""] ], :width => 770, :cell_style => {:border_color=> "ffffff"}, :column_widths => [80,30,60,230,50,50,50,60,50,50,60]) do
		      style(columns(1..2), :align => :center)
		      style(columns(5..10), :align => :right)
		    end
		  }
		when 0
		  pad(1) {
		    table([ ["#{x[0][2]}", "#{x[0][3]}", "#{x[0][5]}", "#{x[0][6]}", "#{x[0][7]}", "", "", "", "#{x[1]}", "#{number_with_precision(1, precision: 2)}", "#{number_with_precision(x[1], precision: 2)}"] ], :width => 770, :cell_style => {:border_color=> "ffffff"}, :column_widths => [80,30,60,230,50,50,50,60,50,50,60]) do
		      style(columns(1..2), :align => :center)
		      style(columns(5..10), :align => :right)
		    end
		  }
	  end

	  stroke_horizontal_rule
  end

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # Kardex Monthly
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  when "2"
    repeat :all do
	  font_size 12

	  text "Kárdex Mensual", :align => :center

	  font_size 8
	  move_down 3

	  table([ [{content:"Almacén", rowspan: 2}, {content:"Periodo", rowspan: 2}, {content:"Código", rowspan: 2}, {content:"Descripción", rowspan: 2}, {content:"Unidad", rowspan: 2},  
	{content: "Ingreso", colspan: 3}, {content: "Salida", colspan: 3}],
	["Cantidad", "C/Unitario", "Costo", "Cantidad", "C/Unitario", "Costo"] ], :width => 770, :column_widths => [80,40,60,220,50,50,50,60,50,50,60])  do
	  style(columns(5..10), :align => :center)
	  end

	  move_down 3
	end

	item = 0
	@reportRows.each do |x|
	  # Page Bring
	  item += 1
	  if item == @rows_per_page
	    start_new_page
	    move_down 60
	    item = 1
	  end
	
	  # Data
	  case x[0][0]
	    when 1
		  pad(1) {
		    table([ ["#{x[0][2]}", "#{x[0][3]}", "#{x[0][9]}", "#{x[0][10]}", "#{x[0][11]}", "#{x[1]}", "#{number_with_precision(1, precision: 2, delimiter: ',')}", "#{number_with_precision(x[1], precision: 2, delimiter: ',')}", "", "", ""] ], :width => 770, :cell_style => {:border_color=> "ffffff"}, :column_widths => [80,40,60,220,50,50,50,60,50,50,60]) do
		      style(columns(1..2), :align => :center)
		      style(columns(5..10), :align => :right)
		    end
		  }
		when 0
		  pad(1) {
		    table([ ["#{x[0][2]}", "#{x[0][3]}", "#{x[0][5]}", "#{x[0][6]}", "#{x[0][7]}", "", "", "", "#{x[1]}", "#{number_with_precision(1, precision: 2, delimiter: ',')}", "#{number_with_precision(x[1], precision: 2, delimiter: ',')}"] ], :width => 770, :cell_style => {:border_color=> "ffffff"}, :column_widths => [80,40,60,220,50,50,50,60,50,50,60]) do
		      style(columns(1..2), :align => :center)
		      style(columns(5..10), :align => :right)
		    end
		  }
	  end

	  stroke_horizontal_rule
	end

  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  # Kardex Detail
  #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  when "3"
	repeat :all do
	  font_size 12

	  text "Kárdex Detallado", :align => :center

	  font_size 8
	  move_down 3

	  table([ [{content:"Almacén", rowspan: 2}, {content:"Periodo", rowspan: 2}, {content:"Fecha", rowspan: 2}, {content:"Código", rowspan: 2}, {content:"Descripción", rowspan: 2}, {content:"Unidad", rowspan: 2},  
	{content: "Ingreso", colspan: 3}, {content: "Salida", colspan: 3}],
	["Cantidad", "C/Unitario", "Costo", "Cantidad", "C/Unitario", "Costo"] ], :width => 770, :column_widths => [80,40,60,60,170,50,50,50,50,50,50,60])  do
	  style(columns(5..10), :align => :center)
	  end

	  move_down 3
	end

	item = 0
	@reportRows.each do |x|
	  # Page Bring
	  item += 1
	  if item == @rows_per_page
	    start_new_page
	    move_down 60
	    item = 1
	  end

	  # Data
	  case x.input
	    when 1
		  pad(1) {
		    table([ ["#{x.warehouse_name}", "#{x.period}", "#{x.issue_date}", "#{x.article_code}", "#{x.article_name}", "#{x.article_symbol}", "#{x.amount}", "#{number_with_precision(1, precision: 2, delimiter: ',')}", "#{number_with_precision(x.amount, precision: 2, delimiter: ',')}", "", "", ""] ], :width => 770, :cell_style => {:border_color=> "ffffff"}, :column_widths => [80,40,60,60,170,50,50,50,50,50,50,60]) do
		      style(columns(1..2), :align => :center)
		      style(columns(5..11), :align => :right)
		    end
		  }
		when 0
		  pad(1) {
		    table([ ["#{x.warehouse_name}", "#{x.period}", "#{x.issue_date}", "#{x.article_code}", "#{x.article_name}", "#{x.article_symbol}", "", "", "", "#{x.amount}", "#{number_with_precision(1, precision: 2, delimiter: ',')}", "#{number_with_precision(x.amount, precision: 2, delimiter: ',')}"] ], :width => 770, :cell_style => {:border_color=> "ffffff"}, :column_widths => [80,40,60,60,170,50,50,50,50,50,50,60]) do
		      style(columns(1..2), :align => :center)
		      style(columns(5..11), :align => :right)
		    end
		  }
	  end

	  stroke_horizontal_rule
	end
end

# footer
page_count.times do |i|
  go_to_page(i+1)
  text "#{i+1} / #{page_count}", :align => :right
end