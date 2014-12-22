class Payslip < ActiveRecord::Base

  belongs_to :worker
  has_one :type_of_payslip

  def self.generate_payroll_workers cost_center_id, week_id, week_start, week_end, wg, ing, des, apo, headers, array_extra_info, array_worker
    
    # => WG - Working Groups
    # => ING - Ingresos
    # => DES - Descuentos
    # => APO - Aportaciones
    array_worker = array_worker.split(',').uniq
    if ing.include?(1)
      incluye = true
    else
      incluye = false
    end

    @result = Array.new
    total_hour = WeeksPerCostCenter.get_total_hours_per_week(cost_center_id, week_id)
    @i = 1
    uit7 = FinancialVariable.find_by_name("UIT").value * 7
    uit27 = FinancialVariable.find_by_name("UIT").value * 27
    uit54 = FinancialVariable.find_by_name("UIT").value * 54
    @result[0] = headers
    @result[0] << "REMUNERACIÓN BÁSICA"
    amount = 0
    apoNa = Array.new
    ActiveRecord::Base.connection.execute("
      SELECT ppd.worker_id, e.dni, CONCAT_WS(' ', e.name, e.second_name, e.paternal_surname, e.maternal_surname), ar.name, pp.date_of_creation, af.type_of_afp, w.numberofchilds, SUM( ppd.normal_hours ) , SUM( 1 ) AS Dias, SUM( ppd.he_60 ) , SUM( ppd.he_100 ) , SUM( ppd.total_hours ), af.id
      FROM part_people pp, part_person_details ppd, entities e, workers w, worker_afps wa, afps af, worker_contracts wc, articles ar
      WHERE pp.cost_center_id = " + cost_center_id.to_s + "
      AND ppd.part_person_id = pp.id
      AND pp.date_of_creation BETWEEN '" + week_start.to_s + "' AND  '" + week_end.to_s + "'
      AND ppd.worker_id = w.id
      AND pp.working_group_id IN ("+wg.to_s+")
      AND w.entity_id = e.id
      AND wa.worker_id = w.id
      AND af.id = wa.afp_id
      AND wc.worker_id = w.id
      AND wc.article_id = ar.id
      GROUP BY ppd.worker_id
    ").each do |row|
      worker_hours = calculate_number_days_worker(row[7].to_f, total_hour.to_f)
      
      @result << [ row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], worker_hours, row[9], row[10] ]
      calculator = Dentaku::Calculator.new
      amount = 0
      flag_extra = false
      if array_worker.include?(row[0].to_s)
        flag_extra = true
      end
      # Remuneracion Básica
      rem_basic = 0
      total = 0
      por_hora = 0
      from_contract = Worker.find(row[0]).worker_contracts.where(:status => 1).first.worker_contract_details.where(:concept_id => 1).first
      if !from_contract.nil?
        if !from_contract.amount.nil?
          rem_basic = (from_contract.amount/total_hour.to_f)*row[7]
          por_hora = from_contract.amount.to_f/total_hour.to_f
 
        else
          article_id = Worker.find(row[0]).worker_contracts.where(:status => 1).first.article_id
          @category_id = Category.find_by_code(Article.find(article_id).code[2..5]).id
          from_category = CategoryOfWorker.find_by_category_id(@category_id).category_of_workers_concepts.where(:concept_id => 1).first
          if from_category.amount != 0
            rem_basic = (from_category.amount.to_f/total_hour.to_f)*row[7]
            por_hora = from_category.amount.to_f/total_hour.to_f
          end
        end
      else
        article_id = Worker.find(row[0]).worker_contracts.where(:status => 1).first.article_id
        @category_id = Category.find_by_code(Article.find(article_id).code[2..5]).id
        from_category = CategoryOfWorker.find_by_category_id(@category_id).category_of_workers_concepts.where(:concept_id => 1).first
        if from_category.amount != 0
          rem_basic = (from_category.amount.to_f/total_hour.to_f)*row[7]
          por_hora = from_category.amount.to_f/total_hour.to_f
        end
      end
      if flag_extra
        array_extra_info.each do |ar|
          if ar[1].to_i == 1 && ar[0].to_i == row[0].to_i
            rem_basic = rem_basic.to_f + ar[2].to_f
          end
        end
      end
      calculator.store(remuneracion_basica: rem_basic)
      calculator.store(precio_por_hora: por_hora)
      calculator.store(horas_trabajadas: row[7])
      calculator.store(horas_totales_semana: total_hour)
      calculator.store(dias_trabajados: worker_hours)
      calculator.store(horas_simples: row[9].to_f)
      calculator.store(horas_dobles: row[10].to_f)
      calculator.store(horas_extras_60: 0)
      calculator.store(horas_extras_100: 0)

      @result[@i] << rem_basic
      if incluye
        total += rem_basic
      end

      if !ing.nil?
        ing.delete(1) # => Removiendo la Remuneracion Basica de todos los Ingresos.
        ing.each do |ing|
          con = nil
          hash_formulas = Hash.new
          formu = nil
          con = Concept.find(ing)
          formu = con.concept_valorizations.where("type_worker = 'worker'").first
          if !@result[0].include?(con.name)
            @result[0] << con.name.to_s
          end

          if !con.concept_valorizations.where("type_worker = 'worker'").first.formula.include? '[monto-contrato-categoria]' # => Token Generico
            contract = Worker.find(row[0]).worker_contracts.where(:status => 1).first.worker_contract_details.where(:concept_id => ing).first
            if !contract.nil?
              if contract.amount != 0 && !contract.amount.nil?
                amount = contract.amount.to_f
                total += amount.to_f
              else
                if !con.concept_valorizations.where("type_worker = 'worker'").first.nil? && con.amount.to_f != 0.0
                  amount = con.amount.to_f
                  total += amount.to_f
                elsif con.concept_valorizations.where("type_worker = 'worker'").first.formula != ''
                  amount = Formule.translate_formules(con.concept_valorizations.where("type_worker = 'worker'").first.formula, rem_basic, row[0], calculator, hash_formulas, con.token)
                  total += amount.to_f
                else
                  amount = 0
                  total += amount.to_f
                end
              end
            else
              article_id = Worker.find(row[0]).worker_contracts.where(:status => 1).where(:status => 1).first.article_id
              category_id = Category.find_by_code(Article.find(article_id).code[2..5]).id
              from_category = CategoryOfWorker.find_by_category_id(category_id).category_of_workers_concepts.where(:concept_id => ing).first
              if !from_category.nil?
                if from_category.amount.to_f != 0.0 && !from_category.amount.nil?
                  amount = from_category.amount
                  total += amount.to_f
                else
                  if !con.concept_valorizations.where("type_worker = 'worker'").first.nil? && con.amount.to_f != 0.0
                    amount = con.amount.to_f
                    total += amount.to_f
                  elsif con.concept_valorizations.where("type_worker = 'worker'").first.formula != ''
                    amount = Formule.translate_formules(con.concept_valorizations.where("type_worker = 'worker'").first.formula, rem_basic, row[0], calculator, hash_formulas, con.token)
                    total += amount.to_f
                  else
                    amount = 0
                    total += amount.to_f
                  end
                end
              else
                if !con.concept_valorizations.where("type_worker = 'worker'").first.nil? && con.amount.to_f != 0.0
                  amount = con.amount.to_f
                  total += amount.to_f
                elsif con.concept_valorizations.where("type_worker = 'worker'").first.formula != ''
                  amount = Formule.translate_formules(con.concept_valorizations.where("type_worker = 'worker'").first.formula, rem_basic, row[0], calculator, hash_formulas, con.token)
                  total += amount.to_f
                else
                  amount = 0
                  total += amount.to_f
                end
              end
            end
          else
            amount = Formule.translate_formules(con.concept_valorizations.where("type_worker = 'worker'").first.formula, rem_basic, row[0], calculator, hash_formulas, con.token, con.id)
            total += amount.to_f
          end
          
          if flag_extra
            array_extra_info.each do |ar|
              if ar[1].to_i == ing.to_i && ar[0].to_i == row[0].to_i
                total-=amount
                amount = amount.to_f + ar[2].to_f
                total += amount
              end
            end
          end
          @result[@i] << amount
        end
        @result[@i] << total
        total1 = total
        total = 0
        amount = 0

        if !@result[0].include?("Ingresos Totales")
          @result[0] << "Ingresos Totales"
        end
      end
      if !des.nil?
        des.each do |de|
          flag_afp = true
          hash_formulas =   Hash.new
          con = Concept.find(de)
          
          if !@result[0].include?(con.name)
            @result[0] << con.name.to_s
          end

          if con.name == 'APORTE FONDO PENSIONES' || con.name == 'PRIMA DE SEGURO' || con.name == 'COMISION FIJA AFP' || con.name == 'AFP SEGURO RIESGO' || con.name == 'IMPTO. RENT. 5ta CAT.' || con.name == 'ORG. NAC. DE PENSIONES'
            flag_afp = false
          end
          contract = Worker.find(row[0]).worker_contracts.where(:status => 1).first.worker_contract_details.where(:concept_id => de).first

          if !contract.nil?
            if contract.amount != 0 && !contract.amount.nil?
              amount = contract.amount.to_f
              total += amount.to_f
            else
              if !con.concept_valorizations.where("type_worker = 'worker'").first.nil? && con.amount.to_f != 0.0
                amount = con.amount.to_f
                total += amount.to_f
              else
                amount = Formule.translate_formules(con.concept_valorizations.where("type_worker = 'worker'").first.formula, rem_basic, row[0], calculator, hash_formulas, con.token)
                if !con.top.nil?
                  if amount.to_f > con.top.to_f && flag_afp
                    amount = con.top.to_f
                  end
                end
                total += amount.to_f
              end
            end
          else
            article_id = Worker.find(row[0]).worker_contracts.where(:status => 1).where(:status => 1).first.article_id
            category_id = Category.find_by_code(Article.find(article_id).code[2..5]).id
            from_category = CategoryOfWorker.find_by_category_id(category_id).category_of_workers_concepts.where(:concept_id => de).first
            if !from_category.nil?
              if from_category.amount.to_f != 0.0 && !from_category.amount.nil?
                amount = from_category.amount
                total += amount.to_f
              else
                if !con.concept_valorizations.where("type_worker = 'worker'").first.nil? && con.amount.to_f != 0.0
                  amount = con.amount.to_f
                  total += amount
                else
                  amount = Formule.translate_formules(con.concept_valorizations.where("type_worker = 'worker'").first.formula, rem_basic, row[0], calculator, hash_formulas, con.token)

                  if !con.top.nil?
                    if amount.to_f > con.top.to_f && flag_afp
                      amount = con.top.to_f
                    end
                  end
                  total += amount.to_f
                end
              end
            else
              if !con.concept_valorizations.where("type_worker = 'worker'").first.nil? && con.amount.to_f != 0.0
                amount = con.amount.to_f
                total += amount
              else
                amount = Formule.translate_formules(con.concept_valorizations.where("type_worker = 'worker'").first.formula, rem_basic, row[0], calculator, hash_formulas, con.token)
                if !con.top.nil?
                  if amount.to_f > con.top.to_f && flag_afp
                    amount = con.top.to_f
                  end
                end
                total += amount.to_f
              end
            end
          end
          afp_d = Afp.find(row[12])
          afp = afp_d.afp_details.where("date_entry BETWEEN '"+week_start.to_s+"' AND '"+ week_end.to_s+"'").first
          if afp.nil?
            afp = Afp.find(row[12])
          end

          if !con.nil?
            if afp_d.type_of_afp == "SNP"
              if con.name == 'ORG. NAC. DE PENSIONES'
                total = total - amount.to_f
                amount = rem_basic * afp.contribution_fp.to_f/100
                if amount > afp.top
                  amount = afp.top
                end
                total += amount.to_f
              end
            else
              if con.name == 'APORTE FONDO PENSIONES'
                total = total - amount.to_f
                amount = rem_basic * afp.contribution_fp.to_f/100
                if amount > afp.top
                  amount = afp.top
                end
                total += amount.to_f  
              end
            end
            if con.name == 'PRIMA DE SEGURO'
              total = total - amount.to_f
              amount = rem_basic * afp.insurance_premium.to_f/100
              if amount > afp.top
                amount = afp.top
              end          
              total += amount.to_f
            elsif con.name == 'COMISION FIJA AFP'
              total = total - amount.to_f
              amount = rem_basic * afp.mixed.to_f/100
              if amount > afp.top
                amount = afp.top
              end          
              total += amount.to_f              
            elsif con.name == 'AFP SEGURO RIESGO'
              total = total - amount.to_f
              amount = rem_basic * afp.c_variable.to_f/100
              if amount > afp.top
                amount = afp.top
              end          
              total += amount.to_f

            elsif con.name == 'IMPTO. RENT. 5ta CAT.'
              total -= amount
              bruto = total1*14*4
              if bruto > uit7 && bruto < uit27
                amount = (bruto - uit7)*0.15/12/4
              elsif bruto > uit27 && bruto < uit54
                dif = bruto - uit7
                amount = uit7*0.15/12/4
                amount += (bruto - uit7)*0.21/12/4
              elsif bruto > uit54
                amount = uit7*0.15/12/4
                amount = (uit27-uit7)*0.21/12/4
                amount += (bruto - uit27 - uit7)*0.3/12/4
              else
                amount = 0
              end
              total+= amount
            end            
          end
          if flag_extra
            array_extra_info.each do |ar|
              if ar[1].to_i == de.to_i && ar[0].to_i == row[0].to_i
                total -= amount
                amount = amount.to_f + ar[2].to_f
                total += amount
              end
            end
          end
          @result[@i] << amount        
        end
        @result[@i] << total
        if !@result[0].include?("Descuentos Totales")
          @result[0] << "Descuentos Totales"
          @result[0] << "Neto"
        end

        @result[@i] << total1 - total
        total = 0

      end

      if !apo.nil?
        apo.each do |ap|
          hash_formulas = Hash.new
          con = Concept.find(ap)
          if !apoNa.include?(con.name)
            @result[0] << con.name.to_s
            apoNa << con.name.to_s
          end
          if !con.concept_valorizations.where("type_worker = 'worker'").first.nil? && con.amount.to_f != 0.0
            amount = con.amount.to_f
            total += amount
            
          else
            amount = Formule.translate_formules(con.concept_valorizations.where("type_worker = 'worker'").first.formula, rem_basic, row[0], calculator, hash_formulas, con.token)
            total += amount.to_f
          end
          if flag_extra
            array_extra_info.each do |ar|
              if ar[1].to_i == ap.to_i && ar[0].to_i == row[0].to_i
                total -= amount
                amount = amount.to_f + ar[2].to_f
                total += amount
              end
            end
          end 
          @result[@i] << amount         
        end
        @result[@i] << total

        if !@result[0].include?("Aportaciones Totales")
          @result[0] << "Aportaciones Totales"
        end
      end
      array_worker.delete(row[0])
      @i+=1

    end

    return @result
  end

  def self.generate_payroll_empleados company, week_start, week_end, ing, des, apo, array_extra_info, array_worker
    
    # => WG - Working Groups
    # => ING - Ingresos
    # => DES - Descuentos
    # => APO - Aportaciones
    array_worker = array_worker.split(',').uniq
    month = week_end.to_date.strftime('%m').to_i
    rangos = FinancialVariable.where("name LIKE 'RANGO %'")
    year = week_end.to_date.strftime('%YYYY').to_i
    if ing.include?(1)
      incluye =true
    else
      incluye = false
    end
    @result = Array.new
    headers = ['DNI', 'Nombre', 'CAT.', 'COMP.', 'AFP', 'HIJ', 'DIAS ASIST.', 'DIAS FALTA', 'HE 25%','HE 35%']
    total_days = 30
    @i = 1
    @comp_name = Company.find(company).short_name
    uit = FinancialVariable.find_by_name("UIT").value
    @result[0] = headers
    @result[0] << "SUELDO BÁSICO"
    amount = 0
    apoNa = Array.new
    ActiveRecord::Base.connection.execute("
      SELECT ppd.worker_id, e.dni, CONCAT_WS(  ' ', e.name, e.second_name, e.paternal_surname, e.maternal_surname ) , ar.name, af.type_of_afp, w.numberofchilds, count(1) AS Dias, af.id, ppd.he_25, ppd.he_35
      FROM part_workers pp, part_worker_details ppd, entities e, workers w, worker_afps wa, afps af, worker_contracts wc, articles ar
      WHERE pp.company_id = "+company.to_s+"
      AND ppd.part_worker_id = pp.id
      AND ppd.assistance =  'si'
      AND pp.date_of_creation BETWEEN '" + week_start.to_s + "' AND  '" + week_end.to_s + "'
      AND ppd.worker_id = w.id
      AND w.entity_id = e.id
      AND wa.worker_id = w.id
      AND af.id = wa.afp_id
      AND wc.worker_id = w.id
      AND wc.article_id = ar.id
      AND wc.status = 1
      GROUP BY w.id
    ").each do |row|

      @result << [ row[0], row[1], row[2], row[3],@comp_name, row[4], row[5], row[6], total_days - row[6], row[8], row[9]]
      calculator = Dentaku::Calculator.new
      amount = 0
      flag_extra = false
      if array_worker.include?(row[0].to_s)
        flag_extra = true
      end
      # Remuneracion Básica
      rem_basic = 0
      total = 0
      por_hora = 0
      from_contract = Worker.find(row[0]).worker_contracts.where(:status => 1).first
      if !from_contract.nil?
        rem_basic = ((from_contract.salary.to_f + from_contract.destaque.to_f)/total_days)*row[6]
        por_hora = ((from_contract.salary.to_f + from_contract.destaque.to_f)/total_days)/8
      end
      if flag_extra
        array_extra_info.each do |ar|
          if ar[1].to_i == 1 && ar[0].to_i == row[0].to_i
            rem_basic = rem_basic.to_f + ar[2].to_f
          end
        end
      end
      @result[@i] << rem_basic
      calculator.store(remuneracion_basica: rem_basic)
      calculator.store(precio_por_hora: por_hora)
      calculator.store(dias_trabajados: row[6])
      calculator.store(horas_simples: row[8].to_f)
      calculator.store(horas_dobles: row[9].to_f)
      calculator.store(horas_dobles: 0)
      calculator.store(horas_extras_25: 0)
      calculator.store(horas_extras_35: 0)

      if incluye
        total += rem_basic
      end

      if !ing.nil?
        ing.delete(1) # => Removiendo la Remuneracion Basica de todos los Ingresos.
        ing.each do |ing|
          con = nil
          hash_formulas = Hash.new
          formu = nil
          con = Concept.find(ing)
          formu = con.concept_valorizations
          if !@result[0].include?(con.name)
            @result[0] << con.name.to_s
          end

          contract = Worker.find(row[0]).worker_contracts.where(:status => 1).first
          amount = Formule.translate_formules_of_employee(con.concept_valorizations.where("type_worker = 'employee'").first.formula, rem_basic, row[0], calculator, hash_formulas, con.token)
          total += amount.to_f
          #if  ing.to_i == 15
            #total = total - amount.to_f
            #amount = amount.to_f * row[6].to_f
            #total+=amount.to_f
          #end

          #if  ing.to_i == 17
            #total = total - amount.to_f
            #amount = amount.to_f * row[8].to_f
            #total += amount.to_f
          #end

          #if  ing.to_i == 24
            #total = total - amount.to_f
            #amount = amount.to_f * row[8].to_f
            #total += amount.to_f
          #end
          if flag_extra
            array_extra_info.each do |ar|
              if ar[1].to_i == ing.to_i && ar[0].to_i == row[0].to_i
                total-=amount
                amount = amount.to_f + ar[2].to_f
                total += amount
              end
            end
          end
          @result[@i] << amount
        end
        @result[@i] << total
        total1 = total
        total = 0
        amount = 0

        if !@result[0].include?("Ingresos Totales")
          @result[0] << "Ingresos Totales"
        end
      end

      if !des.nil?
        des.each do |de|
          flag_afp = true
          hash_formulas = Hash.new
          con = Concept.find(de)
          
          if !@result[0].include?(con.name)
            @result[0] << con.name.to_s
          end

          if con.name == 'APORTE FONDO PENSIONES' || con.name == 'PRIMA DE SEGURO' || con.name == 'COMISION FIJA AFP' || con.name == 'AFP SEGURO RIESGO' || con.name == 'IMPTO. RENT. 5ta CAT.' || con.name == 'ORG. NAC. DE PENSIONES'
            flag_afp = false
          end
          amount = Formule.translate_formules_of_employee(con.concept_valorizations.where("type_worker = 'employee'").first.formula, rem_basic, row[0], calculator, hash_formulas, con.token)
          if !con.top.nil?
            if amount.to_f > con.top.to_f && flag_afp
              amount = con.top.to_f
            end
          end
          total += amount.to_f

          afp_d = Afp.find(row[7])
          afp = afp_d.afp_details.where("date_entry BETWEEN '"+week_start.to_s+"' AND '"+ week_end.to_s+"'").first
          if afp.nil?
            afp = Afp.find(row[7])
          end

          if !con.nil?
            if afp_d.type_of_afp == "SNP"
              if con.name == 'ORG. NAC. DE PENSIONES'
                total = total - amount.to_f
                amount = rem_basic * afp.contribution_fp.to_f/100
                if amount > afp.top
                  amount = afp.top
                end
                total += amount.to_f
              end
            else
              if con.name == 'APORTE FONDO PENSIONES'
                total = total - amount.to_f
                amount = rem_basic * afp.contribution_fp.to_f/100
                if amount > afp.top
                  amount = afp.top
                end
                total += amount.to_f  
              end
            end
            
            if con.name == 'PRIMA DE SEGURO'
              total = total - amount.to_f
              amount = rem_basic * afp.insurance_premium.to_f/100
              if amount > afp.top
                amount = afp.top
              end          
              total += amount.to_f
            elsif con.name == 'COMISION FIJA AFP'
              total = total - amount.to_f
              amount = rem_basic * afp.mixed.to_f/100
              if amount > afp.top
                amount = afp.top
              end          
              total += amount.to_f              
            elsif con.name == 'AFP SEGURO RIESGO'
              total = total - amount.to_f
              amount = rem_basic * afp.c_variable.to_f/100
              if amount > afp.top
                amount = afp.top
              end          
              total += amount.to_f

            elsif con.name == 'IMPTO. RENT. 5ta CAT.'
              total -= amount
              suma_mes = amount
              amount = 0
              to_end_year = 13 - month.to_i
              initial = 0
              final = 0
              value = 0
              flag_inside_rank = true
              array_rank_previous = Array.new
              value_previous = 0
              puts "------------------------------------------------------------------------------------------------------------------------------------"
              p "[remuneracion-basica]+[horas-simples]*[precio-por-hora]+[horas-dobles]*[precio-por-hora]+[cts]+[gratificaciones]"
              p calculator.inspect
              puts suma_mes
              p to_end_year
              rangos.each do |ran|
                p ran.inspect
                if flag_inside_rank
                  num = ran.name.scan(/\[.*?\]/).first.tr('][','')
                  if to_end_year == 12
                    anual_income = suma_mes*14
                  else
                    anual_income = suma_mes*to_end_year+2*suma_mes
                  end
                  p anual_income
                  if num.split('-').count > 1
                    initial = num.split('-')[0].to_i*uit
                    p initial
                    final = num.split('-')[1].to_i*uit
                    p final
                    value = ran.value
                    p value
                    if anual_income < final && anual_income > initial
                      p '----------entro a anual income < final && anual_income > initial------------------------------------------------------------------'
                      amount = ((anual_income-initial)*value + value_previous)/12
                      p amount
                      flag_inside_rank = false
                    else
                      if anual_income > initial
                        p "----------------------- anual_income > initial ------------------------------------------------------------------------------"
                        value_previous += (final-initial)*value
                        p value_previous
                      else
                        p " ----------------------------------------------- falso?----------------------------------------------------------------------"
                        p anual_income > initial
                        flag_inside_rank = false
                      end
                    end
                  elsif num.split('-').count == 1
                    initial = num.gsub('+','').to_i*uit
                    value = ran.value
                    if anual_income > initial
                      amount = ((anual_income-initial)*value + value_previous)/12
                      flag_inside_rank = false
                    end 
                  end
                end
              end
              total+= amount   
              p amount        
            end            
          end

          if flag_extra
            array_extra_info.each do |ar|
              if ar[1].to_i == de.to_i
                total -= amount
                amount = amount.to_f + ar[2].to_f
                total += amount
              end
            end
          end
          @result[@i] << amount        
        end
        @result[@i] << total
        if !@result[0].include?("Descuentos Totales")
          @result[0] << "Descuentos Totales"
          @result[0] << "Neto"
        end

        @result[@i] << total1 - total
        total = 0

      end

      break

      if !apo.nil?
        apo.each do |ap|
          hash_formulas = Hash.new
          con = Concept.find(ap)
          if !apoNa.include?(con.name)
            @result[0] << con.name.to_s
            apoNa << con.name.to_s
          end
          
          amount = Formule.translate_formules_of_employee(con.concept_valorizations.where("type_worker = 'employee'").first.formula, rem_basic, row[0], calculator, hash_formulas, con.token)
          total += amount.to_f

          if flag_extra
            array_extra_info.each do |ar|
              if ar[1].to_i == ap.to_i && ar[0].to_i == row[0].to_i
                total -= amount
                amount = amount.to_f + ar[2].to_f
                total += amount
              end
            end
          end 
          @result[@i] << amount         
        end
        @result[@i] << total

        if !@result[0].include?("Aportaciones Totales")
          @result[0] << "Aportaciones Totales"
        end
      end

      array_worker.delete(row[0])
      @i+=1
    end

    return @result
  end



  def self.calculate_number_days_worker total_hours_worker, total_hour_week
    if total_hours_worker >= total_hour_week
      return 6
    else
      return (total_hours_worker*6/total_hour_week).round()
    end
  end

end
