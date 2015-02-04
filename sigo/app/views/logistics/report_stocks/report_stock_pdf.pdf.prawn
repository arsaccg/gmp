bounding_box [bounds.left, bounds.bottom + 780], :width  => bounds.width do
  table([ ["A&R S.A.C. Contratistas Generales"] ], :width => 100, :cell_style => {:height => 72}, :column_widths => [100]) do
          style(row(0), :valign => :center)
          style(row(0), :align => :center)
          style(columns(0), :size => 12)
          columns(0).font_style = :bold
        end
end
bounding_box [bounds.left + 100, bounds.bottom + 780], :width  => bounds.width do
  table([ ["Reporte de Stock"] ], :width => 280, :cell_style => {:height => 72}, :column_widths => [280]) do
          style(row(0), :valign => :center)
          style(column(0), :align => :center)
          style(columns(0), :size => 12)
          columns(0).font_style = :bold
        end
end
bounding_box [bounds.left + 380, bounds.bottom + 780], :width  => bounds.width do
  table([ ["#{@costcenter}"],["Fecha: #{@date.strftime("%d/%m/%Y")}"],["Página: 1 de 1"] ], :width => 140, :cell_style => {:height => 24}, :column_widths => [140]) do
          style(columns(0), :align => :center)
          style(columns(0), :size => 8)
          columns(0).font_style = :bold
        end
end

move_down 20

table([ ["CÓDIGO", "NOMBRE", "CANTIDAD", "UND"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [100,280,140]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0..2).font_style = :bold
      end

@articleresult.each do |result|
	table([ ["#{result[0]}", "#{result[1]}", "#{result[2]}", "#{result[3]}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [100,280,140]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
      end
end