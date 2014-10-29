index = 1
bounding_box [bounds.left, bounds.bottom + 788], :width  => bounds.width do
  table([ ["A&R S.A.C. Contratistas Generales"] ], :width => 100, :cell_style => {:height => 64}, :column_widths => [100]) do
          style(row(0), :valign => :center)
          style(row(0), :align => :center)
          style(columns(0), :size => 10)
          columns(0).font_style = :bold
        end
end
bounding_box [bounds.left + 100, bounds.bottom + 788], :width  => bounds.width do
  table([ ["FICHA DE PERSONAL"] ], :width => 320, :cell_style => {:height => 64}, :column_widths => [320]) do
          style(row(0), :valign => :center)
          style(column(0), :align => :center)
          style(columns(0), :size => 10)
          columns(0).font_style = :bold
        end
end
bounding_box [bounds.left + 420, bounds.bottom + 788], :width  => bounds.width do
  table([ ["ARSAC-CMASS-F-063"],["Rev.: 01"],["Fecha: #{@date.strftime("%d/%m/%Y")}"],["Página: #{index} de "] ], :width => 100, :cell_style => {:height => 16}, :column_widths => [100]) do
          style(columns(0), :align => :center)
          style(columns(0), :size => 7)
          columns(0).font_style = :bold
        end
end
move_down 15

text "I. DATOS PERSONALES", :size => 9
bounding_box [bounds.left + 440, bounds.bottom + 690], :width  => bounds.width do
  table([ [""] ], :width => 80, :cell_style => {:height => 96}, :column_widths => [80])
end
bounding_box [bounds.left + 0, bounds.bottom + 690], :width  => bounds.width do
  table([ ["CÓDIGO", "APELLIDO PATERNO", "APELLIDO MATERNO","NOMBRES"] ], :width => 440, :cell_style => {:height => 16}, :column_widths => [60,100,100,180]) do
          style(columns(0..3), :align => :center)
          style(columns(0..3), :size => 7)
          style(columns(0..3), :valign => :center)
          columns(0..3).font_style = :bold
          style(row(0), :background_color => 'A0D8A0')
        end
end
table([ ["#{@worker.id.to_s}", "#{@worker.entity.paternal_surname.to_s}", "#{@worker.entity.maternal_surname.to_s}","#{@worker.entity.name.to_s} #{@worker.entity.second_name.to_s}"] ], :width => 440, :cell_style => {:height => 16}, :column_widths => [60,100,100,180]) do
        style(columns(0..3), :align => :center)
        style(columns(0..3), :size => 7)
          style(columns(0..3), :valign => :center)
      end
table([ ["LUGAR DE NACIMIENTO(CIUDAD-PROVINCIA-DEPARTAMENTO)", "EDAD","FECH.NAC."] ], :width => 440, :cell_style => {:height => 16}, :column_widths => [285,80,75]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 7)
        style(columns(0..2), :valign => :center)
        columns(0..2).font_style = :bold
        style(row(0), :background_color => 'A0D8A0')
      end
table([ ["#{@worker.entity.city.to_s} - #{@worker.entity.province.to_s} - #{@worker.entity.department.to_s}", "#{@edad}","#{@worker.entity.date_of_birth.strftime("%d/%m/%Y").to_s}"] ], :width => 440, :cell_style => {:height => 16}, :column_widths => [285,80,75]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :valign => :center)
        style(columns(0..2), :size => 7)
      end
table([ ["DNI", "C. EXTRANJERIA"] ], :width => 440, :cell_style => {:height => 16}, :column_widths => [220,220]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :valign => :center)
        style(columns(0..2), :size => 7)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        style(row(0), :background_color => 'A0D8A0')
      end
table([ ["#{@worker.entity.dni.to_s}", "#{@worker.entity.alienslicense.to_s.upcase}"] ], :width => 440, :cell_style => {:height => 16}, :column_widths => [220,220]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :valign => :center)
        style(columns(0..2), :size => 7)
      end
table([ ["#{@nombre.to_s}", "CODIGO UNICO S.P.P", "N° DE CUENTA DE AHORROS", "BANCO"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [130,130,120,140]) do
        style(columns(0..3), :align => :center)
        style(columns(0..3), :valign => :center)
        style(columns(0..3), :size => 7)
        columns(0..3).font_style = :bold
        style(row(0), :background_color => 'A0D8A0')
      end
table([ [if "#{@afp}"!="" then "#{@afp.afp.enterprise}" else "-" end, if "#{@afp}"!="" then "#{@afp.afpnumber.to_s}" else "-" end, if "#{@bank}"!="" then "#{@bank.account_number}" end, if "#{@bank}"!="" then "#{@bank.bank.business_name.upcase}" end] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [130,130,120,140]) do
        style(columns(0..4), :align => :center)
        style(columns(0..4), :valign => :center)
        style(columns(0..4), :size => 7)
      end
table([ ["SEXO", "#{@worker.entity.gender.upcase}", "ESTADO CIVIL", "#{@worker.maritalstatus.to_s.upcase}", "LICENCIA DE CONDUCIR", "#{@worker.driverlicense.to_s}"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [60,80,80,90,120,90]) do
        style(columns(0..5), :align => :center)
        style(columns(0..5), :valign => :center)
        style(columns(0..5), :size => 7)
        columns(0).font_style = :bold
        columns(2).font_style = :bold
        columns(4).font_style = :bold
        style(column(0), :background_color => 'A0D8A0')
        style(column(2), :background_color => 'A0D8A0')
        style(column(4), :background_color => 'A0D8A0')
      end

move_down 10

text "II. DOMICILIO", :size => 9
table([ ["CALLE / AV. / JIRON - N° / MZ / LOTE - URBANIZACION - CIUDAD "] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [520]) do
        style(columns(0), :align => :center)
        style(columns(0), :valign => :top)
        style(columns(0), :size => 7)
        columns(0).font_style = :bold
        style(row(0), :background_color => 'A0D8A0')
      end
table([ ["#{@worker.address.to_s}"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [520]) do
        style(columns(0), :align => :center)
        style(columns(0), :size => 7)
      end
table([ ["DISTRITO)", "PROVINCIA","DEPARTAMENTO"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [170,170,180]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 7)
        columns(0..2).font_style = :bold
        style(row(0), :background_color => 'A0D8A0')
      end
table([ ["#{@worker.district.to_s}", "#{@worker.province.to_s}","#{@worker.department.to_s}"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [170,170,180]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 7)
      end
table([ ["PAIS", "TELEFONO FIJO", "CELULAR", "E-MAIL"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [130,130,130,130]) do
        style(columns(0..3), :align => :center)
        style(columns(0..3), :size => 7)
        columns(0..3).font_style = :bold
        style(row(0), :background_color => 'A0D8A0')
      end
table([ ["#{@worker.pais.to_s}", "#{@worker.phone.to_s}", "#{@worker.cellphone.to_s}", "#{@worker.email.to_s}"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [130,130,130,130]) do
        style(columns(0..4), :align => :center)
        style(columns(0..4), :size => 7)
      end

move_down 10

text "III. DATOS FAMILIARES (PADRES-CONYUGE-HIJOS)", :size => 9
if @familiars == 0
  table([ ["AP. PATERNO", "AP. MATERNO", "NOMBRES", "PARENTESCO", "F. DE NACIM.", "DNI"],["", "", "", "", "", ""],["", "", "", "", "", ""],["", "", "", "", "", ""],["", "", "", "", "", ""],["", "", "", "", "", ""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [100,100,120,70,70,60]) do
          style(columns(0..5), :align => :center)
          style(columns(0..5), :size => 7)
          columns(0..5).font_style = :bold
          style(row(0), :background_color => 'A0D8A0')
        end
else
  table([ ["AP. PATERNO", "AP. MATERNO", "NOMBRES", "PARENTESCO", "F. DE NACIM.", "DNI"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [100,100,120,70,70,60]) do
          style(columns(0..5), :align => :center)
          style(columns(0..5), :size => 7)
          columns(0..5).font_style = :bold
          style(row(0), :background_color => 'A0D8A0')
        end
  @worker_familiars.each do |data|
    table([ ["#{data.paternal_surname}", "#{data.maternal_surname}", "#{data.names}", "#{data.relationship}", if "#{data.dayofbirth}"!="" then "#{data.dayofbirth.strftime("%d/%m/%Y")}" end, "#{data.dni}"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [100,100,120,70,70,60]) do
          style(columns(0..5), :align => :center)
            style(columns(0..5), :size => 7)
          end
  end
  (0..(5-("#{@worker_familiars.count}").to_i-1)).each do |something|
    table([ ["", "", "", "", "", ""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [100,100,120,70,70,60]) do
          style(columns(0..5), :align => :center)
          style(columns(0..5), :size => 7)
          columns(0..5).font_style = :bold
        end
  end
end

move_down 10

text "IV. EDUCACION", :size => 9
if @worker.lastgrade.nil?
  table([ ["SITUACION EDUCATIVA", "#{@worker.levelofinstruction.to_s.upcase}"] ], :width => 500, :cell_style => {:height => 16}, :column_widths => [100,400]) do
          style(columns(0..1), :align => :center)
          style(columns(0..1), :size => 7)
          columns(0..1).font_style = :bold
          style(column(0), :background_color => 'A0D8A0')
        end
else
  table([ ["SITUACION EDUCATIVA", "#{@worker.levelofinstruction.to_s}","","Último ciclo/año/grado cursado","#{@worker.lastgrade}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [95,165,10,170,80]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 8)
          columns(0..4).font_style = :bold
          columns(2).border_top_color = "ffffff"
          columns(2).border_bottom_color = "ffffff"
          style(column(0), :background_color => 'A0D8A0')
          style(column(3), :background_color => 'A0D8A0')
        end
end
move_down 10
table([ ["ESTUDIOS", "COLEGIO", "LUGAR", "DESDE", "HASTA"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [70,200,130,60,60]) do
        style(columns(0..4), :align => :center)
        style(columns(0..4), :size => 7)
        columns(0..4).font_style = :bold
        style(row(0), :background_color => 'A0D8A0')
      end
table([ ["PRIMARIA", "#{@worker.primaryschool}", "#{@worker.primarydistrict}", "#{@worker.primarystartdate.to_s}", "#{@worker.primaryenddate.to_s}"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [70,200,130,60,60]) do
        style(columns(0..4), :align => :center)
        style(columns(0..4), :size => 7)
        columns(0).font_style = :bold
        style(column(0), :background_color => 'A0D8A0')
      end
table([ ["SECUNDARIA", "#{@worker.highschool}", "#{@worker.highschooldistrict}", "#{@worker.highschoolstartdate.to_s}", "#{@worker.highschoolenddate.to_s}"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [70,200,130,60,60]) do
        style(columns(0..4), :align => :center)
        style(columns(0..4), :size => 7)
        columns(0).font_style = :bold
        style(column(0), :background_color => 'A0D8A0')
      end
move_down 10
if cursor()<170
  start_new_page
  index += 1
  bounding_box [bounds.left, bounds.bottom + 788], :width  => bounds.width do
    table([ ["A&R S.A.C. Contratistas Generales"] ], :width => 100, :cell_style => {:height => 64}, :column_widths => [100]) do
            style(row(0), :valign => :center)
            style(row(0), :align => :center)
            style(columns(0), :size => 10)
            columns(0).font_style = :bold
          end
  end
  bounding_box [bounds.left + 100, bounds.bottom + 788], :width  => bounds.width do
    table([ ["FICHA DE PERSONAL"] ], :width => 320, :cell_style => {:height => 64}, :column_widths => [320]) do
            style(row(0), :valign => :center)
            style(column(0), :align => :center)
            style(columns(0), :size => 10)
            columns(0).font_style = :bold
          end
  end
  bounding_box [bounds.left + 420, bounds.bottom + 788], :width  => bounds.width do
    table([ ["ARSAC-CMASS-F-063"],["Rev.: 01"],["Fecha: #{@date.strftime("%d/%m/%Y")}"],["Página: #{index} de "] ], :width => 100, :cell_style => {:height => 16}, :column_widths => [100]) do
            style(columns(0), :align => :center)
            style(columns(0), :size => 7)
            columns(0).font_style = :bold
          end
  end
  move_down 10
end
if @worker_center_of_studies.count < 1
  table([ ["UNIVERSIDAD/INSTITUTO", "PROFESION", "TITULO/GRADO", "N° COLEG.", "DESDE", "HASTA"],["", "", "", "", "", ""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [160,100,70,70,60,60]) do
          style(columns(0..5), :align => :center)
          style(columns(0..5), :size => 7)
          columns(0..5).font_style = :bold
          style(row(0), :background_color => 'A0D8A0')
        end
  (0..1).each do |something|
    table([ [" ", " ", " ", " ", " ", " "] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [160,100,70,70,60,60]) do
          style(columns(0..5), :align => :center)
            style(columns(0..5), :size => 7)
          end
  end
else
  table([ ["UNIVERSIDAD/INSTITUTO", "PROFESION", "TITULO/GRADO", "N° COLEG.", "DESDE", "HASTA"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [160,100,70,70,60,60]) do
          style(columns(0..5), :align => :center)
          style(columns(0..5), :size => 7)
          columns(0..5).font_style = :bold
          style(row(0), :background_color => 'A0D8A0')
        end
  @worker_center_of_studies.each do |data|
    table([ ["#{data.name}", "#{data.profession}", "#{data.title}", "#{data.numberoftuition}", if "#{data.start_date}"!="" then "#{data.start_date.to_s}" end, if "#{data.end_date}"!="" then "#{data.end_date.to_s}" end] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [160,100,70,70,60,60]) do
          style(columns(0..5), :align => :center)
            style(columns(0..5), :size => 7)
          end
  end
  (0..(3-("#{@worker_center_of_studies.count}").to_i-1)).each do |something|
    table([ ["", "", "", "", "", ""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [160,100,70,70,60,60]) do
          style(columns(0..5), :align => :center)
          style(columns(0..5), :size => 7)
          columns(0..5).font_style = :bold
        end
  end
end
move_down 10
if cursor()<130
  start_new_page
  index += 1
  bounding_box [bounds.left, bounds.bottom + 788], :width  => bounds.width do
    table([ ["A&R S.A.C. Contratistas Generales"] ], :width => 100, :cell_style => {:height => 64}, :column_widths => [100]) do
            style(row(0), :valign => :center)
            style(row(0), :align => :center)
            style(columns(0), :size => 10)
            columns(0).font_style = :bold
          end
  end
  bounding_box [bounds.left + 100, bounds.bottom + 788], :width  => bounds.width do
    table([ ["FICHA DE PERSONAL"] ], :width => 320, :cell_style => {:height => 64}, :column_widths => [320]) do
            style(row(0), :valign => :center)
            style(column(0), :align => :center)
            style(columns(0), :size => 10)
            columns(0).font_style = :bold
          end
  end
  bounding_box [bounds.left + 420, bounds.bottom + 788], :width  => bounds.width do
    table([ ["ARSAC-CMASS-F-063"],["Rev.: 01"],["Fecha: #{@date.strftime("%d/%m/%Y")}"],["Página: #{index} de "] ], :width => 100, :cell_style => {:height => 16}, :column_widths => [100]) do
            style(columns(0), :align => :center)
            style(columns(0), :size => 7)
            columns(0).font_style = :bold
          end
  end
  move_down 10
end
if @worker_otherstudies.count < 1
  table([ ["OTROS ESTUDIOS/CONOCIMIENTOS", "NIVEL"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [190,330]) do
    style(columns(0..1), :align => :center)
    style(columns(0..1), :size => 7)
    columns(0..1).font_style = :bold
    style(row(0), :background_color => 'A0D8A0')
  end
  (0..2).each do |something|
    table([ ["","Básico","","Intermedio","","Avanzado",""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [190,90,20,90,20,90,20]) do
          style(columns(0..6), :align => :center)
          style(columns(0..6), :size => 7)
          end
  end
else
  table([ ["OTROS ESTUDIOS/CONOCIMIENTOS", "NIVEL"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [190,330]) do
          style(columns(0..1), :align => :center)
          style(columns(0..1), :size => 7)
          columns(0..1).font_style = :bold
          style(row(0), :background_color => 'A0D8A0')
        end
  @worker_otherstudies.each do |data|
    table([ ["#{data.study}", "Básico", if "#{data.level}"=="basico" then 'X' end,"Intermedio",if "#{data.level}"=="intermedio" then 'X' end,"Avanzado",if "#{data.level}"=="avanzado" then 'X' end] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [190,90,20,90,20,90,20]) do
            style(columns(0..6), :align => :center)
            style(columns(0..6), :size => 7)
          end
  end
  (0..(3-("#{@worker_otherstudies.count}").to_i-1)).each do |something|
    table([ ["", "","", "","", "",""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [190,90,20,90,20,90,20]) do
          style(columns(0..6), :align => :center)
          style(columns(0..6), :size => 7)
        end
  end
end
if cursor()<130
  start_new_page
  index += 1
  bounding_box [bounds.left, bounds.bottom + 788], :width  => bounds.width do
    table([ ["A&R S.A.C. Contratistas Generales"] ], :width => 100, :cell_style => {:height => 64}, :column_widths => [100]) do
            style(row(0), :valign => :center)
            style(row(0), :align => :center)
            style(columns(0), :size => 10)
            columns(0).font_style = :bold
          end
  end
  bounding_box [bounds.left + 100, bounds.bottom + 788], :width  => bounds.width do
    table([ ["FICHA DE PERSONAL"] ], :width => 320, :cell_style => {:height => 64}, :column_widths => [320]) do
            style(row(0), :valign => :center)
            style(column(0), :align => :center)
            style(columns(0), :size => 10)
            columns(0).font_style = :bold
          end
  end
  bounding_box [bounds.left + 420, bounds.bottom + 788], :width  => bounds.width do
    table([ ["ARSAC-CMASS-F-063"],["Rev.: 01"],["Fecha: #{@date.strftime("%d/%m/%Y")}"],["Página: #{index} de "] ], :width => 100, :cell_style => {:height => 16}, :column_widths => [100]) do
            style(columns(0), :align => :center)
            style(columns(0), :size => 7)
            columns(0).font_style = :bold
          end
  end
  move_down 10
end
move_down 10

text "IV. EXPERIENCIA (DETALLE DE LOS ULTIMOS TRABAJOS EN ORDEN DESCENDENTE)", :size => 9
if @experiencies == 0
  table([ ["NOMBRE DE LA EMPRESA","Cargo"],["",""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [260,260]) do
          style(columns(0..1), :align => :center)
          style(columns(0..1), :size => 7)
          row(0).font_style = :bold
          style(row(0), :background_color => 'A0D8A0')
        end
  table([ ["SUELDO (S/.)", "JEFE INMEDIATO", "MOTIVO DE SALIDA", "DESDE", "HASTA"],["", "", "", "", ""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [100,160,100,80,80]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 7)
          row(0).font_style = :bold
          style(row(0), :background_color => 'A0D8A0')
        end
  table([ ["NOMBRE DE LA EMPRESA","Cargo"],["",""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [260,260]) do
          style(columns(0..1), :align => :center)
          style(columns(0..1), :size => 7)
          row(0).font_style = :bold
          style(row(0), :background_color => 'A0D8A0')
        end
  table([ ["SUELDO (S/.)", "JEFE INMEDIATO", "MOTIVO DE SALIDA", "DESDE", "HASTA"],["", "", "", "", ""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [100,160,100,80,80]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 7)
          row(0).font_style = :bold
          style(row(0), :background_color => 'A0D8A0')
        end
  table([ ["NOMBRE DE LA EMPRESA","Cargo"],["",""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [260,260]) do
          style(columns(0..1), :align => :center)
          style(columns(0..1), :size => 7)
          row(0).font_style = :bold
          style(row(0), :background_color => 'A0D8A0')
        end
  table([ ["SUELDO (S/.)", "JEFE INMEDIATO", "MOTIVO DE SALIDA", "DESDE", "HASTA"],["", "", "", "", ""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [100,160,100,80,80]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 7)
          row(0).font_style = :bold
          style(row(0), :background_color => 'A0D8A0')
        end
else
  @worker_experiences.each do |data|
    table([ ["NOMBRE DE LA EMPRESA","Cargo"],["#{data.businessname.to_s}","#{data.title.to_s}"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [260,260]) do
            style(columns(0..1), :align => :center)
            style(columns(0..1), :size => 7)
            row(0).font_style = :bold
            style(row(0), :background_color => 'A0D8A0')
          end
    table([ ["SUELDO (S/.)", "JEFE INMEDIATO", "MOTIVO DE SALIDA", "DESDE", "HASTA"],["#{data.salary.to_s}", "#{data.bossincharge.to_s}", "#{data.exitreason.to_s}", "#{data.start_date.to_s}", "#{data.end_date.to_s}"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [100,160,100,80,80]) do
            style(columns(0..4), :align => :center)
            style(columns(0..4), :size => 7)
            row(0).font_style = :bold
          style(row(0), :background_color => 'A0D8A0')
          end
  end
  (0..(3-("#{@worker_experiences.count}").to_i-1)).each do |something|
    table([ ["NOMBRE DE LA EMPRESA","Cargo"],["",""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [260,260]) do
          style(columns(0..1), :align => :center)
          style(columns(0..1), :size => 7)
          row(0).font_style = :bold
          style(row(0), :background_color => 'A0D8A0')
          end
    table([ ["SUELDO (S/.)", "JEFE INMEDIATO", "MOTIVO DE SALIDA", "DESDE", "HASTA"],["", "", "", "", ""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [100,160,100,80,80]) do
            style(columns(0..4), :align => :center)
            style(columns(0..4), :size => 7)
            row(0).font_style = :bold
            style(row(0), :background_color => 'A0D8A0')
          end
  end
end
move_down 10

if (@worker.quality == "si")
  table([ ["TIENE CONOCIMIENTOS DE NORMAS DE CALIDAD?","SI","X","NO",""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [360,40,40,40,40]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 7)
          columns(0..4).font_style = :bold
        end
else
  table([ ["TIENE CONOCIMIENTOS DE NORMAS DE CALIDAD?","SI","","NO","X"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [360,40,40,40,40]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 7)
          columns(0..4).font_style = :bold
        end
end
if (@worker.security == "si")
  table([ ["TIENE CONOCIMIENTOS DE NORMAS DE SEGURIDAD?","SI","X","NO",""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [360,40,40,40,40]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 7)
          columns(0..4).font_style = :bold
        end
else
  table([ ["TIENE CONOCIMIENTOS DE NORMAS DE SEGURIDAD?","SI","","NO","X"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [360,40,40,40,40]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 7)
          columns(0..4).font_style = :bold
        end
end
if (@worker.enviroment == "si")
  table([ ["TIENE CONOCIMIENTOS DE NORMAS DE MEDIOAMBIENTE?","SI","X","NO",""]], :width => 520, :cell_style => {:height => 16}, :column_widths => [360,40,40,40,40]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 7)
          columns(0..4).font_style = :bold
        end
else
  table([ ["TIENE CONOCIMIENTOS DE NORMAS DE MEDIOAMBIENTE?","SI","","NO","X"]], :width => 520, :cell_style => {:height => 16}, :column_widths => [360,40,40,40,40]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 7)
          columns(0..4).font_style = :bold
        end
end
if (@worker.labor_legislation == "si")
  table([ ["TIENE CONOCIMIENTOS DE LA LEGISLACION LABORAL?","SI","X","NO",""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [360,40,40,40,40]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 7)
          columns(0..4).font_style = :bold
        end
else
  table([ ["TIENE CONOCIMIENTOS DE LA LEGISLACION LABORAL?","SI","","NO","X"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [360,40,40,40,40]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 7)
          columns(0..4).font_style = :bold
        end
end

move_down 10

text "V. DOCUMENTACION ADJUNTA", :size => 9
table([ ["CURRICULUM VITAE DOCUMENTADO", if "#{@worker.cv_file_size}"!="" then 'X' end, "PARTIDA DE NACIMIENTO DE HIJOS", if "#{@worker.birth_certificate_of_childer_file_size}"!="" then 'X' end] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [240,20,240,20]) do
        style(columns(0..3), :align => :left)
        style(columns(0..3), :valign => :middle)
        style(columns(0..3), :size => 7)
        columns(0..3).font_style = :bold
      end
table([ ["CERTIFICADO DE ANTECEDENTES POLICIALES", if "#{@worker.antecedent_police_file_size}"!="" then 'X' end, "DNI HIJOS Y ESPOSA", if "#{@worker.dni_wife_kids_file_size}"!="" then 'X' end] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [240,20,240,20]) do
        style(columns(0..3), :align => :left)
        style(columns(0..3), :valign => :middle)
        style(columns(0..3), :size => 7)
        columns(0..3).font_style = :bold
      end
table([ ["DOCUMENTO NACIONAL DE IDENTIDAD", if "#{@worker.dni_file_size}"!="" then 'X' end, "CONSTANCIA MATRICULA ESCOLAR", if "#{@worker.schoolar_certificate_file_size}"!="" then 'X' end] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [240,20,240,20]) do
        style(columns(0..3), :align => :left)
        style(columns(0..3), :size => 7)
        columns(0..3).font_style = :bold
      end
table([ ["CARTA DE DEPOSITO C.T.S.", if "#{@worker.cts_deposit_letter_file_size}"!="" then 'X' end , "CERTIFICADO DE CONVIVENCIA / PARTIDA DE MATRIMONIO", if "#{@worker.marriage_certificate_file_size}"!="" then 'X' end] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [240,20,240,20]) do
        style(columns(0..3), :align => :left)
        style(columns(0..3), :size => 7)
        columns(0..3).font_style = :bold
      end
table([ ["CARTA DE FONDOS PREVISIONALES", if "#{@worker.pension_funds_letter_file_size}"!="" then 'X' end, "",""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [240,20,240,20]) do
        style(columns(0..3), :align => :left)
        style(columns(0..3), :size => 7)
        columns(0..3).font_style = :bold
      end
table([ ["DECLARACION JURADA DE RENTA DE 5TA", if "#{@worker.affidavit_file_size}"!="" then 'X' end , "", ""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [240,20,240,20]) do
        style(columns(0..3), :align => :left)
        style(columns(0..3), :size => 7)
        columns(0..3).font_style = :bold
      end
move_down 10

text "NOTA: Declaro que los datos consignados se ajustan a la verdad y que de ser necesario me comprometo a sustentarlos fisicamente con la documentacion que corresponda.", :size => 9

move_down 10
if cursor()<130
  start_new_page
  index += 1
  bounding_box [bounds.left, bounds.bottom + 788], :width  => bounds.width do
    table([ ["A&R S.A.C. Contratistas Generales"] ], :width => 100, :cell_style => {:height => 64}, :column_widths => [100]) do
            style(row(0), :valign => :center)
            style(row(0), :align => :center)
            style(columns(0), :size => 10)
            columns(0).font_style = :bold
          end
  end
  bounding_box [bounds.left + 100, bounds.bottom + 788], :width  => bounds.width do
    table([ ["FICHA DE PERSONAL"] ], :width => 320, :cell_style => {:height => 64}, :column_widths => [320]) do
            style(row(0), :valign => :center)
            style(column(0), :align => :center)
            style(columns(0), :size => 10)
            columns(0).font_style = :bold
          end
  end
  bounding_box [bounds.left + 420, bounds.bottom + 788], :width  => bounds.width do
    table([ ["ARSAC-CMASS-F-063"],["Rev.: 01"],["Fecha: #{@date.strftime("%d/%m/%Y")}"],["Página: #{index} de "] ], :width => 100, :cell_style => {:height => 16}, :column_widths => [100]) do
            style(columns(0), :align => :center)
            style(columns(0), :size => 7)
            columns(0).font_style = :bold
          end
  end
  move_down 10
end
if @workercontract.nil?
  text "VI. DATOS CONTRACTUALES (LLENADO POR LA EMPRESA)", :size => 9
  table([ ["C.C","FECHA DE INGRESO", "CARGO", "CODIGO TOBI", "SUELDO (S/.)"],["", "", "", "", ""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [80,100,140,85,115]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 7)
          row(0).font_style = :bold
          style(row(0), :background_color => 'A0D8A0')
        end
  move_down 10
  table([ ["OBRA", "#{@worker.cost_center.cost_center_detail.name}"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [80,440]) do
          style(columns(0..1), :align => :center)
          style(columns(0..1), :size => 7)
          columns(0).font_style = :bold
          style(column(0), :background_color => 'A0D8A0')
        end
  table([ ["DISTRITO)", "PROVINCIA","DEPARTAMENTO"],["#{@worker.cost_center.cost_center_detail.district.to_s}", "#{@worker.cost_center.cost_center_detail.province.to_s}","#{@worker.cost_center.cost_center_detail.department.to_s}"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [170,170,180]) do
          style(columns(0..2), :align => :center)
          style(columns(0..2), :size => 7)
          row(0).font_style = :bold
          style(row(0), :background_color => 'A0D8A0')
        end
else
  text "VI. DATOS CONTRACTUALES (LLENADO POR LA EMPRESA)", :size => 9
  table([ ["C.C.","FECHA DE INGRESO", "CARGO", "CODIGO TOBI", "SUELDO (S/.)"],["#{@worker.cost_center.code.to_s}","#{@workercontract.start_date.to_s}", "#{@workercontract.article.name.to_s rescue ''}", "#{@workercontract.article.code.to_s rescue ''}", "#{@workercontract.salary.to_s}"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [80,100,140,85,115]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 7)
          row(0).font_style = :bold
          style(row(0), :background_color => 'A0D8A0')
        end
  move_down 10
  table([ ["OBRA", "#{@worker.cost_center.cost_center_detail.name.to_s}"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [80,440]) do
          style(columns(0..1), :align => :center)
          style(columns(0..1), :size => 7)
          columns(0).font_style = :bold
          style(column(0), :background_color => 'A0D8A0')
        end
  if cursor()<130
    start_new_page
    index += 1
    bounding_box [bounds.left, bounds.bottom + 788], :width  => bounds.width do
      table([ ["A&R S.A.C. Contratistas Generales"] ], :width => 100, :cell_style => {:height => 64}, :column_widths => [100]) do
              style(row(0), :valign => :center)
              style(row(0), :align => :center)
              style(columns(0), :size => 10)
              columns(0).font_style = :bold
            end
    end
    bounding_box [bounds.left + 100, bounds.bottom + 788], :width  => bounds.width do
      table([ ["FICHA DE PERSONAL"] ], :width => 320, :cell_style => {:height => 64}, :column_widths => [320]) do
              style(row(0), :valign => :center)
              style(column(0), :align => :center)
              style(columns(0), :size => 10)
              columns(0).font_style = :bold
            end
    end
    bounding_box [bounds.left + 420, bounds.bottom + 788], :width  => bounds.width do
      table([ ["ARSAC-CMASS-F-063"],["Rev.: 01"],["Fecha: #{@date.strftime("%d/%m/%Y")}"],["Página: #{index} de "] ], :width => 100, :cell_style => {:height => 16}, :column_widths => [100]) do
              style(columns(0), :align => :center)
              style(columns(0), :size => 7)
              columns(0).font_style = :bold
            end
    end
    move_down 10
  end
  table([ ["DISTRITO)", "PROVINCIA","DEPARTAMENTO"],["#{@worker.cost_center.cost_center_detail.district.to_s}", "#{@worker.cost_center.cost_center_detail.province.to_s}","#{@worker.cost_center.cost_center_detail.department.to_s}"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [170,170,180]) do
          style(columns(0..2), :align => :center)
          style(columns(0..2), :size => 7)
          row(0).font_style = :bold
          style(row(0), :background_color => 'A0D8A0')
        end
end
move_down 10
if cursor()<130
  start_new_page
  index += 1
  bounding_box [bounds.left, bounds.bottom + 788], :width  => bounds.width do
    table([ ["A&R S.A.C. Contratistas Generales"] ], :width => 100, :cell_style => {:height => 64}, :column_widths => [100]) do
            style(row(0), :valign => :center)
            style(row(0), :align => :center)
            style(columns(0), :size => 10)
            columns(0).font_style = :bold
          end
  end
  bounding_box [bounds.left + 100, bounds.bottom + 788], :width  => bounds.width do
    table([ ["FICHA DE PERSONAL"] ], :width => 320, :cell_style => {:height => 64}, :column_widths => [320]) do
            style(row(0), :valign => :center)
            style(column(0), :align => :center)
            style(columns(0), :size => 10)
            columns(0).font_style = :bold
          end
  end
  bounding_box [bounds.left + 420, bounds.bottom + 788], :width  => bounds.width do
    table([ ["ARSAC-CMASS-F-063"],["Rev.: 01"],["Fecha: #{@date.strftime("%d/%m/%Y")}"],["Página: #{index} de "] ], :width => 100, :cell_style => {:height => 16}, :column_widths => [100]) do
            style(columns(0), :align => :center)
            style(columns(0), :size => 7)
            columns(0).font_style = :bold
          end
  end
  move_down 10
end
table([ ["TRABAJADOR", "V°B° GERENCIA GENERAL"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [260,260]) do
        style(columns(0..1), :align => :center)
        style(columns(0..1), :size => 7)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
      end
table([ ["", "", ""] ], :width => 520, :cell_style => {:height => 61}, :column_widths => [70,190,260]) do
        style(columns(0..2), :align => :center)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
      end
table([ ["OBRA", "V°B° ADMINISTRACION CENTRAL"] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [260,260]) do
        style(columns(0..1), :align => :center)
        style(columns(0..1), :size => 7)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
      end
table([ ["REGISTRADO POR:", "APROBADO POR:",""] ], :width => 520, :cell_style => {:height => 16}, :column_widths => [130,130,260]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 7)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(2).border_bottom_color = "ffffff"
      end
table([ ["", "", ""] ], :width => 520, :cell_style => {:height => 50}, :column_widths => [130,130,260]) do
        columns(2).border_top_color = "ffffff"
      end
total = "#{pdf.page_count}"
repeat :all do
  bounding_box [bounds.left + 493, bounds.bottom + 732], :width  => 200 do
    text "#{total}", :size => 7, :style => :bold
  end
end