bounding_box [bounds.left, bounds.bottom + 780], :width  => bounds.width do
  table([ ["A&R S.A.C. Contratistas Generales"] ], :width => 100, :cell_style => {:height => 72}, :column_widths => [100]) do
          style(row(0), :valign => :center)
          style(row(0), :align => :center)
          style(columns(0), :size => 12)
          columns(0).font_style = :bold
        end
end
bounding_box [bounds.left + 100, bounds.bottom + 780], :width  => bounds.width do
  table([ ["FICHA DE PERSONAL"] ], :width => 320, :cell_style => {:height => 72}, :column_widths => [320]) do
          style(row(0), :valign => :center)
          style(column(0), :align => :center)
          style(columns(0), :size => 12)
          columns(0).font_style = :bold
        end
end
bounding_box [bounds.left + 420, bounds.bottom + 780], :width  => bounds.width do
  table([ ["ARSAC-CMASS-F-063"],["Rev.: 01"],["Fecha: #{@date.strftime("%d/%m/%Y")}"],["Página: 1 de 2"] ], :width => 100, :cell_style => {:height => 18}, :column_widths => [100]) do
          style(columns(0), :align => :center)
          style(columns(0), :size => 8)
          columns(0).font_style = :bold
        end
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
table([ ["#{@worker.id.to_s}", "#{@worker.entity.paternal_surname.to_s}", "#{@worker.entity.maternal_surname.to_s}","#{@worker.entity.name.to_s} #{@worker.entity.second_name.to_s}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [80,110,110,220]) do
        style(columns(0..3), :align => :center)
        style(columns(0..3), :size => 8)
      end
table([ ["LUGAR DE NACIMIENTO(CIUDAD-PROVINCIA-DEPARTAMENTO)", "EDAD","FECH.NAC."] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [320,100,100]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
      end
table([ ["#{@worker.entity.city.to_s} #{@worker.entity.province.to_s} #{@worker.entity.department.to_s}", "#{@edad}","#{@worker.entity.date_of_birth.to_s}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [320,100,100]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
      end
table([ ["DNI", "C. EXTRANJERIA"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [260,260]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
      end
table([ ["#{@worker.entity.dni.to_s}", "#{@worker.entity.alienslicense.to_s}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [260,260]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
      end
table([ ["#{@nombre.to_s}", "CODIGO UNICO S.P.P", "TIPO DE CUENTA", "N° DE CUENTA", "BANCO"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [110,110,80,100,120]) do
        style(columns(0..4), :align => :center)
        style(columns(0..4), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
        columns(3).font_style = :bold
        columns(4).font_style = :bold
      end
table([ [if "#{@afp}"!="" then "#{@afp.afp.enterprise}" else "-" end, "#{@worker.afpnumber.to_s}", "", if "#{@bank}"!="" then "#{@bank.account_number}" end, if "#{@bank}"!="" then "#{@bank.bank.business_name}" end] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [110,110,80,100,120]) do
        style(columns(0..4), :align => :center)
        style(columns(0..4), :size => 8)
      end
table([ ["SEXO", "#{@worker.entity.gender}", "ESTADO CIVIL", "#{@worker.maritalstatus.to_s}", "LICENCIA DE CONDUCIR", "#{@worker.driverlicense.to_s}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [60,80,80,90,120,90]) do
        style(columns(0..5), :align => :center)
        style(columns(0..5), :size => 8)
        columns(0).font_style = :bold
        columns(2).font_style = :bold
        columns(4).font_style = :bold
      end

move_down 10

text "II. DOMICILIO", :size => 9
table([ ["CALLE / AV. / JIRON - N° / MZ / LOTE - URBANIZACION - CIUDAD "] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [520]) do
        style(columns(0), :align => :center)
        style(columns(0), :size => 8)
        columns(0).font_style = :bold
      end
table([ ["#{@worker.address.to_s}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [520]) do
        style(columns(0), :align => :center)
        style(columns(0), :size => 8)
      end
table([ ["DISTRITO)", "PROVINCIA","DEPARTAMENTO"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [170,170,180]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
        columns(0).font_style = :bold
        columns(1).font_style = :bold
        columns(2).font_style = :bold
      end
table([ ["#{@worker.district.to_s}", "#{@worker.province.to_s}","#{@worker.department.to_s}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [170,170,180]) do
        style(columns(0..2), :align => :center)
        style(columns(0..2), :size => 8)
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
table([ ["#{@worker.pais.to_s}", "#{@worker.phone.to_s}", "#{@worker.cellphone.to_s}", "#{@worker.cellphone.to_s}", "#{@worker.email.to_s}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [104,104,104,104,104]) do
        style(columns(0..4), :align => :center)
        style(columns(0..4), :size => 8)
      end

move_down 10

text "III. DATOS FAMILIARES (PADRES-CONYUGE-HIJOS)", :size => 9
if @familiars == 0
  table([ ["AP. PATERNO", "AP. MATERNO", "NOMBRES", "PARENTESCO", "F. DE NACIM.", "DNI"],["", "", "", "", "", ""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [100,100,120,70,70,60]) do
          style(columns(0..5), :align => :center)
          style(columns(0..5), :size => 8)
          columns(0..5).font_style = :bold
        end
else
  table([ ["AP. PATERNO", "AP. MATERNO", "NOMBRES", "PARENTESCO", "F. DE NACIM.", "DNI"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [100,100,120,70,70,60]) do
          style(columns(0..5), :align => :center)
          style(columns(0..5), :size => 8)
          columns(0..5).font_style = :bold
        end
  @worker_familiars.each do |data|
    table([ ["#{data.paternal_surname}", "#{data.maternal_surname}", "#{data.names}", "#{data.relationship}", "#{data.dayofbirth}", "#{data.dni}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [160,100,70,70,60,60]) do
          style(columns(0..5), :align => :center)
            style(columns(0..5), :size => 8)
          end
  end
end

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
      end
table([ ["SECUNDARIA", "#{@worker.highschool}", "#{@worker.highschooldistrict}", "#{@worker.highschoolstartdate}", "#{@worker.highschoolenddate}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [70,200,130,60,60]) do
        style(columns(0..4), :align => :center)
        style(columns(0..4), :size => 8)
        columns(0).font_style = :bold
      end
move_down 10
if @center_of_studies == 0
  table([ ["UNIVERSIDAD/INSTITUTO", "PROFESION", "TITULO/GRADO", "N° COLEG.", "DESDE", "HASTA"],["", "", "", "", "", ""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [160,100,70,70,60,60]) do
          style(columns(0..5), :align => :center)
          style(columns(0..5), :size => 8)
          columns(0..5).font_style = :bold
        end
else
  table([ ["UNIVERSIDAD/INSTITUTO", "PROFESION", "TITULO/GRADO", "N° COLEG.", "DESDE", "HASTA"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [160,100,70,70,60,60]) do
          style(columns(0..5), :align => :center)
          style(columns(0..5), :size => 8)
          columns(0..5).font_style = :bold
        end
  @worker_center_of_studies.each do |data|
    table([ ["#{data.name}", "#{data.profession}", "#{data.title}", "#{data.numberoftuition}", "#{data.start_date}", "#{data.end_date}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [160,100,70,70,60,60]) do
          style(columns(0..5), :align => :center)
            style(columns(0..5), :size => 8)
          end
  end
end
move_down 10
if @otherstudies==0
  table([ ["OTROS ESTUDIOS (POST GRADO)/CONOCIMIENTOS", "NIVEL"],["",""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [400,120]) do
          style(columns(0..1), :align => :center)
          style(columns(0..1), :size => 8)
          columns(0..1).font_style = :bold
        end
else
  table([ ["OTROS ESTUDIOS (POST GRADO)/CONOCIMIENTOS", "NIVEL"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [400,120]) do
          style(columns(0..1), :align => :center)
          style(columns(0..1), :size => 8)
          columns(0..1).font_style = :bold
        end
  @worker_otherstudies.each do |data|
    table([ ["#{data.study}", "#{data.level}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [400,120]) do
            style(columns(0..1), :align => :center)
            style(columns(0..1), :size => 8)
          end
  end
end

start_new_page

bounding_box [bounds.left, bounds.bottom + 780], :width  => bounds.width do
  table([ ["A&R S.A.C. Contratistas Generales"] ], :width => 100, :cell_style => {:height => 72}, :column_widths => [100]) do
          style(row(0), :valign => :center)
          style(row(0), :align => :center)
          style(columns(0), :size => 12)
          columns(0).font_style = :bold
        end
end
bounding_box [bounds.left + 100, bounds.bottom + 780], :width  => bounds.width do
  table([ ["FICHA DE PERSONAL"] ], :width => 320, :cell_style => {:height => 72}, :column_widths => [320]) do
          style(row(0), :valign => :center)
          style(column(0), :align => :center)
          style(columns(0), :size => 12)
          columns(0).font_style = :bold
        end
end
bounding_box [bounds.left + 420, bounds.bottom + 780], :width  => bounds.width do
  table([ ["ARSAC-CMASS-F-063"],["Rev.: 01"],["Fecha: #{@date.strftime("%d/%m/%Y")}"],["Página: 2 de 2"] ], :width => 100, :cell_style => {:height => 18}, :column_widths => [100]) do
          style(columns(0), :align => :center)
          style(columns(0), :size => 8)
          columns(0).font_style = :bold
        end
end
move_down 15

text "IV. EXPERIENCIA (DETALLE DE LOS ULTIMOS TRABAJOS EN ORDEN DESCENDENTE)", :size => 9
if @experiencies == 0
  table([ ["NOMBRE DE LA EMPRESA"],[""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [520]) do
          style(columns(0), :align => :center)
          style(columns(0), :size => 8)
          columns(0).font_style = :bold
        end
  table([ ["CARGO", "SUELDO (S/.)", "JEFE INMEDIATO", "MOTIVO DE SALIDA", "DESDE", "HASTA"],["", "", "", "", "", ""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [80,80,140,100,60,60]) do
          style(columns(0..5), :align => :center)
          style(columns(0..5), :size => 8)
          columns(0..5).font_style = :bold
        end
else
  @worker_experiences.each do |data|
    table([ ["NOMBRE DE LA EMPRESA"],["#{data.businessname.to_s}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [520]) do
            style(columns(0), :align => :center)
            style(columns(0), :size => 8)
            columns(0).font_style = :bold
          end
    table([ ["CARGO", "SUELDO (S/.)", "JEFE INMEDIATO", "MOTIVO DE SALIDA", "DESDE", "HASTA"],["#{data.title.to_s}", "#{data.salary.to_s}", "#{data.bossincharge.to_s}", "#{data.exitreason.to_s}", "#{data.start_date.to_s}", "#{data.end_date.to_s}"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [80,80,140,100,60,60]) do
            style(columns(0..5), :align => :center)
            style(columns(0..5), :size => 8)
            columns(0..5).font_style = :bold
          end
  end
end
move_down 10

if (@worker.quality == "si")
  table([ ["TIENE CONOCIMIENTOS DE NORMAS DE CALIDAD?","SI","X","NO",""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [360,40,40,40,40]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 8)
          columns(0..4).font_style = :bold
        end
else
  table([ ["TIENE CONOCIMIENTOS DE NORMAS DE CALIDAD?","SI","","NO","X"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [360,40,40,40,40]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 8)
          columns(0..4).font_style = :bold
        end
end
if (@worker.security == "si")
  table([ ["TIENE CONOCIMIENTOS DE NORMAS DE SEGURIDAD?","SI","X","NO",""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [360,40,40,40,40]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 8)
          columns(0..4).font_style = :bold
        end
else
  table([ ["TIENE CONOCIMIENTOS DE NORMAS DE SEGURIDAD?","SI","","NO","X"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [360,40,40,40,40]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 8)
          columns(0..4).font_style = :bold
        end
end
if (@worker.enviroment == "si")
  table([ ["TIENE CONOCIMIENTOS DE NORMAS DE MEDIOAMBIENTE?","SI","X","NO",""]], :width => 520, :cell_style => {:height => 18}, :column_widths => [360,40,40,40,40]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 8)
          columns(0..4).font_style = :bold
        end
else
  table([ ["TIENE CONOCIMIENTOS DE NORMAS DE MEDIOAMBIENTE?","SI","","NO","X"]], :width => 520, :cell_style => {:height => 18}, :column_widths => [360,40,40,40,40]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 8)
          columns(0..4).font_style = :bold
        end
end
if (@worker.labor_legislation == "si")
  table([ ["TIENE CONOCIMIENTOS DE LA LEGISLACION LABORAL?","SI","X","NO",""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [360,40,40,40,40]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 8)
          columns(0..4).font_style = :bold
        end
else
  table([ ["TIENE CONOCIMIENTOS DE LA LEGISLACION LABORAL?","SI","","NO","X"] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [360,40,40,40,40]) do
          style(columns(0..4), :align => :center)
          style(columns(0..4), :size => 8)
          columns(0..4).font_style = :bold
        end
end

move_down 10

text "V. DOCUMENTACION ADJUNTA", :size => 9
table([ ["CURRICULUM VITAE DOCUMENTADO", if "#{@worker.cv_file_size}"!="" then 'X' end, "DECLARACION JURADA", if "#{@worker.affidavit_file_size}"!="" then 'X' end] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [240,20,240,20]) do
        style(columns(0..5), :align => :center)
        style(columns(0..5), :size => 8)
        columns(0..5).font_style = :bold
      end
table([ ["CERTIFICADO DE ANTECEDENTES POLICIALES", if "#{@worker.antecedent_police_file_size}"!="" then 'X' end, "CARTA DE FONDOS PREVISIONALES", if "#{@worker.pension_funds_letter_file_size}"!="" then 'X' end] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [240,20,240,20]) do
        style(columns(0..5), :align => :center)
        style(columns(0..5), :size => 8)
        columns(0..5).font_style = :bold
      end
table([ ["CERTIFICADO DE ANTECEDENTES PENALES", "", "PARTIDA DE NACIMIENTO DE HIJOS", if "#{@worker.birth_certificate_of_childer_file_size}"!="" then 'X' end] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [240,20,240,20]) do
        style(columns(0..5), :align => :center)
        style(columns(0..5), :size => 8)
        columns(0..5).font_style = :bold
      end
table([ ["CONSTANCIA MATRICULA ESCOLAR", if "#{@worker.schoolar_certificate_file_size}"!="" then 'X' end, "DNI HIJOS Y ESPOSA", if "#{@worker.dni_wife_kids_file_size}"!="" then 'X' end] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [240,20,240,20]) do
        style(columns(0..5), :align => :center)
        style(columns(0..5), :size => 8)
        columns(0..5).font_style = :bold
      end
table([ ["CERTIFICADO DE CONVIVENCIA", if "#{@worker.marriage_certificate_file_size}"!="" then 'X' end, "DOCUMENTO NACIONAL DE IDENTIDAD", if "#{@worker.dni_file_size}"!="" then 'X' end] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [240,20,240,20]) do
        style(columns(0..5), :align => :center)
        style(columns(0..5), :size => 8)
        columns(0..5).font_style = :bold
      end
table([ ["CARTA DE DEPOSITO C.T.S.", if "#{@worker.cts_deposit_letter_file_size}"!="" then 'X' end , "OTROS", ""] ], :width => 520, :cell_style => {:height => 18}, :column_widths => [240,20,240,20]) do
        style(columns(0..5), :align => :center)
        style(columns(0..5), :size => 8)
        columns(0..5).font_style = :bold
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