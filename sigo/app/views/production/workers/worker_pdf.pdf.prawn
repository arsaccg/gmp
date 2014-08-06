table([ ["", "", "ARSAC-CMASS-F-063"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [100,320,100]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
      end
table([ ["A & R S.A.C.", "", "Rev.: 01"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [100,320,100]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
      end
table([ ["Contratistas", "FICHA DE PERSONAL", "Fecha: "] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [100,320,100]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
      end
table([ ["Generales", "", "Página: 1 de 2"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [100,320,100]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
      end

move_down 15

text "I. DATOS PERSONALES", :size => 9

table([ ["CÓDIGO", "APELLIDO PATERNO", "APELLIDO MATERNO","NOMBRES"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [80,110,110,220]) do
        style(columns(0..3), :align => :center)
        style(columns(0..3), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
      end
table([ ["#{@worker.id}", "#{@worker.entity.paternal_surname}", "#{@worker.entity.maternal_surname}","#{@worker.entity.name} #{@worker.entity.second_name}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [80,110,110,220]) do
        style(columns(0..3), :align => :center)
        style(columns(0..3), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
      end
table([ ["LUGAR DE NACIMIENTO(CIUDAD-PROVINCIA-DEPARTAMENTO)", "EDAD","FECH.NAC."] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [320,100,100]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
      end
table([ ["#{@worker.entity.city} #{@worker.entity.province} #{@worker.entity.department}", "","#{@worker.entity.date_of_birth}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [320,100,100]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
      end
table([ ["DNI", "C. EXTRANJERIA"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [260,260]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
      end
table([ ["#{@worker.entity.dni}", "#{@worker.entity.alienslicense}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [260,260]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
      end
table([ ["NOMBRE DE AFP", "CODIGO UNICO S.P.P", "TIPO DE CUENTA", "N° DE CUENTA", "BANCO"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [110,110,80,100,120]) do
        style(columns(0..4), :align => :center)
        style(columns(0..4), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
        columns(4).font_style = :bold
      end
table([ ["", "#{@worker.afpnumber}", "", "", ""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [110,110,80,100,120]) do
        style(columns(0..4), :align => :center)
        style(columns(0..4), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
        columns(4).font_style = :bold
      end
table([ ["SEXO", "#{@worker.entity.gender}", "ESTADO CIVIL", "#{@worker.maritalstatus}", "LICENCIA DE CONDUCIR", "#{@worker.driverlicense}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [60,80,80,90,120,90]) do
        style(columns(0..5), :align => :center)
        style(columns(0..5), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
        columns(4).font_style = :bold
        columns(5).font_style = :bold
      end

move_down 10

text "II. DOMICILIO", :size => 9
table([ ["CALLE / AV. / JIRON - N° / MZ / LOTE - URBANIZACION - CIUDAD "] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [520]) do
        style(columns(0), :align => :center)
        style(columns(0), :size => 8)
        columns(0).font_style = :bold
      end
table([ ["#{@worker.address}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [520]) do
        style(columns(0), :align => :center)
        style(columns(0), :size => 8)
        columns(0).font_style = :bold
      end
table([ ["DISTRITO)", "PROVINCIA","DEPARTAMENTO"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [170,170,180]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
      end
table([ ["#{@worker.district}", "#{@worker.province}","#{@worker.department}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [170,170,180]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
      end
table([ ["PAIS", "TELEFONO FIJO", "CELULAR", "NEXTEL", "E-MAIL"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [104,104,104,104,104]) do
        style(columns(0..4), :align => :center)
        style(columns(0..4), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
        columns(4).font_style = :bold
      end
table([ ["#{@worker.pais}", "#{@worker.phone}", "#{@worker.cellphone}", "#{@worker.cellphone}", "#{@worker.email}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [104,104,104,104,104]) do
        style(columns(0..4), :align => :center)
        style(columns(0..4), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
        columns(4).font_style = :bold
      end

move_down 10

text "III. DATOS FAMILIARES (PADRES-CONYUGE-HIJOS)", :size => 9

move_down 10

text "IV. EDUCACION", :size => 9
table([ ["ESTUDIOS", "COLEGIO", "LUGAR", "DESDE", "HASTA"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [70,200,130,60,60]) do
        style(columns(0..4), :align => :center)
        style(columns(0..4), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
        columns(4).font_style = :bold
      end
table([ ["PRIMARIA", "#{@worker.primaryschool}", "#{@worker.primarydistrict}", "#{@worker.primarystartdate}", "#{@worker.primaryenddate}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [70,200,130,60,60]) do
        style(columns(0..4), :align => :center)
        style(columns(0..4), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
        columns(4).font_style = :bold
      end
table([ ["SECUNDARIA", "#{@worker.highschool}", "#{@worker.highschooldistrict}", "#{@worker.highschoolstartdate}", "#{@worker.highschoolenddate}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [70,200,130,60,60]) do
        style(columns(0..4), :align => :center)
        style(columns(0..4), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
        columns(4).font_style = :bold
      end
table([ ["UNIVERSIDAD/INSTITUTO", "PROFESION", "TITULO/GRADO", "N° COLEG.", "DESDE", "HASTA"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [160,100,70,70,60,60]) do
        style(columns(0..5), :align => :center)
        style(columns(0..5), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
        columns(4).font_style = :bold
        columns(5).font_style = :bold
      end

move_down 10

table([ ["OTROS ESTUDIOS (POST GRADO)/CONOCIMIENTOS", "UNIVERSIDAD/INSTITUTO", "DESDE","HASTA"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [220,180,60,60]) do
        style(columns(0..3), :align => :center)
        style(columns(0..3), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
      end


start_new_page

text "IV. EXPERIENCIA (DETALLE DE LOS ULTIMOS TRABAJOS EN ORDEN DESCENDENTE)", :size => 9
table([ ["NOMBRE DE LA EMPRESA"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [520]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
      end
table([ [""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [520]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
      end
table([ ["CARGO", "SUELDO (S/.)", "JEFE INMEDIATO", "MOTIVO DE SALIDA", "DESDE", "HASTA"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [80,80,140,100,60,60]) do
        style(columns(0..5), :align => :center)
        style(columns(0..5), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
        columns(4).font_style = :bold
        columns(5).font_style = :bold
      end
table([ ["", "", "", "", "", ""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [80,80,140,100,60,60]) do
        style(columns(0..5), :align => :center)
        style(columns(0..5), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
        columns(4).font_style = :bold
        columns(5).font_style = :bold
      end

move_down 10

table([ ["TIENE CONOCIMIENTOS DE NORMAS DE CALIDAD?", "SI", "", "NO", "", "TIENE CONOCIMIENTOS DE NORMAS DE MEDIOAMBIENTE?", "SI", "", "NO", ""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [160,25,25,25,25,160,25,25,25,25]) do
        style(columns(0..9), :align => :center)
        style(columns(0..9), :size => 8)
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
      end
table([ ["TIENE CONOCIMIENTOS DE NORMAS DE SEGURIDAD?", "SI", "", "NO", "", "TIENE CONOCIMIENTOS DE LA LEGISLACION LABORAL?", "SI", "", "NO", ""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [160,25,25,25,25,160,25,25,25,25]) do
        style(columns(0..9), :align => :center)
        style(columns(0..9), :size => 8)
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
      end

move_down 10

text "V. DOCUMENTACION ADJUNTA", :size => 9
table([ ["CURRICULUM VITAE DOCUMENTADO", "", "CERTIFICADO DE ESTUDIOS SUPERIORES", "", "CARTA DE DEPOSITO C.T.S.", ""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [160,20,150,20,150,20]) do
        style(columns(0..5), :align => :center)
        style(columns(0..5), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
        columns(4).font_style = :bold
        columns(5).font_style = :bold
      end
table([ ["CERTIFICADO DE ANTECEDENTES POLICIALES", "", "CARTA DE FONDOS PREVISIONALES", "", "OTROS", ""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [160,20,150,20,150,20]) do
        style(columns(0..5), :align => :center)
        style(columns(0..5), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
        columns(4).font_style = :bold
        columns(5).font_style = :bold
      end
table([ ["CERTIFICADO DE ANTECEDENTES PENALES", "", "PARTIDA DE NACIMIENTO", "", "", ""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [160,20,150,20,150,20]) do
        style(columns(0..5), :align => :center)
        style(columns(0..5), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
        columns(4).font_style = :bold
        columns(5).font_style = :bold
      end
table([ ["CERTIFICADO DOMICILIARIO", "", "PARTIDA DE MATRIMONIO", "", "", ""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [160,20,150,20,150,20]) do
        style(columns(0..5), :align => :center)
        style(columns(0..5), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
        columns(4).font_style = :bold
        columns(5).font_style = :bold
      end
table([ ["CERTIFICADO DE CONVIVENCIA", "", "DOCUMENTO NACIONAL DE IDENTIDAD", "", "", ""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [160,20,150,20,150,20]) do
        style(columns(0..5), :align => :center)
        style(columns(0..5), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
        columns(4).font_style = :bold
        columns(5).font_style = :bold
      end

move_down 10

text "NOTA: Declaro que los datos consignados se ajustan a la verdad y que de ser necesario me comprometo a sustentarlos fisicamente con la documentacion que corresponda.", :size => 9

move_down 10

text "VI. DATOS CONTRACTUALES (LLENADO POR LA EMPRESA)", :size => 9
table([ ["FECHA DE INGRESO", "CARGO", "SUELDO", "SECTOR/FRENTE", "NOMBRE SECTOR/FRENTE"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [100,140,80,85,115]) do
        style(columns(0..4), :align => :center)
        style(columns(0..4), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
        columns(4).font_style = :bold
      end
table([ ["", "", "", "", ""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [100,140,80,85,115]) do
        style(columns(0..4), :align => :center)
        style(columns(0..4), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
        columns(4).font_style = :bold
      end

move_down 10
table([ ["OBRA", ""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [80,440]) do
        style(columns(0..1), :align => :center)
        style(columns(0..1), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
      end
table([ ["DISTRITO)", "PROVINCIA","DEPARTAMENTO"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [170,170,180]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
      end
table([ ["", "",""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [170,170,180]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
      end

move_down 10

table([ ["TRABAJADOR", "V°B° GERENCIA GENERAL"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [260,260]) do
        style(columns(0..1), :align => :center)
        style(columns(0..1), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
      end
table([ ["", "", ""] ], :width => 520, :cell_style => {:height => 70}, :column_widths => [70,190,260]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
      end
table([ ["OBRA", "V°B° ADMINISTRACION CENTRAL"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [260,260]) do
        style(columns(0..1), :align => :center)
        style(columns(0..1), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
      end
table([ ["REGISTRADO POR:", "APROBADO POR:",""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [130,130,260]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(2).border_bottom_color = "ffffff"
      end
table([ ["", "", ""] ], :width => 520, :cell_style => {:height => 70}, :column_widths => [130,130,260]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).border_top_color = "ffffff"
      end