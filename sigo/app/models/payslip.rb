class Payslip < ActiveRecord::Base

  belongs_to :worker

  def self.generate_payroll_workers cost_center_id, week_id, week_start, week_end, wg, ing, des, apo, headers
    
    # => WG - Working Groups
    # => ING - Ingresos
    # => DES - Descuentos
    # => APO - Aportaciones

    @result = Array.new
    total_hour = WeeksPerCostCenter.get_total_hours_per_week(cost_center_id, week_id)
    @i = 1
    uit = FinancialVariable.find_by_name("UIT").value * 7
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
      
      calculator.store(remuneracion_basica: rem_basic)
      calculator.store(precio_por_hora: por_hora)
      calculator.store(horas_trabajadas: row[7])
      calculator.store(horas_totales_semana: total_hour)
      calculator.store(dias_trabajados: worker_hours)
      calculator.store(horas_simples: row[9])
      calculator.store(horas_dobles: row[10])
      calculator.store(horas_extras_60: 0)
      calculator.store(horas_extras_100: 0)

      @result[@i] << rem_basic
      
      total += rem_basic

      ing.delete("1") # => Removiendo la Remuneracion Basica de todos los Ingresos.
      if !ing.nil?
        ing.each do |ing|
          con = nil
          hash_formulas = Hash.new
          formu = nil
          con = Concept.find(ing)
          formu = con.concept_valorization
          if !@result[0].include?(con.name)
            @result[0] << con.name.to_s
          end

          if !con.concept_valorization.formula.include? '[monto-contrato-categoria]' # => Token Generico
            contract = Worker.find(row[0]).worker_contracts.where(:status => 1).first.worker_contract_details.where(:concept_id => ing).first
            if !contract.nil?
              if contract.amount != 0 && !contract.amount.nil?
                amount = contract.amount.to_f
                total += amount.to_f
              else
                if con.concept_valorization.nil? && con.amount.to_f != 0.0
                  amount = con.amount.to_f
                  total += amount.to_f
                elsif con.concept_valorization.formula != ''
                  amount = Formule.translate_formules(con.concept_valorization.formula, rem_basic, row[0], calculator, hash_formulas, con.token)
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
                  if con.concept_valorization.nil? && con.amount.to_f != 0.0
                    amount = con.amount.to_f
                    total += amount.to_f
                  elsif con.concept_valorization.formula != ''
                    amount = Formule.translate_formules(con.concept_valorization.formula, rem_basic, row[0], calculator, hash_formulas, con.token)
                    total += amount.to_f
                  else
                    amount = 0
                    total += amount.to_f
                  end
                end
              else
                if con.concept_valorization.nil? && con.amount.to_f != 0.0
                  amount = con.amount.to_f
                  total += amount.to_f
                elsif con.concept_valorization.formula != ''
                  amount = Formule.translate_formules(con.concept_valorization.formula, rem_basic, row[0], calculator, hash_formulas, con.token)
                  total += amount.to_f
                else
                  amount = 0
                  total += amount.to_f
                end
              end
            end
          else
            amount = Formule.translate_formules(con.concept_valorization.formula, rem_basic, row[0], calculator, hash_formulas, con.token, con.id)
            total += amount.to_f
          end

          if  ing.to_i == 15
            total = total - amount.to_f
            amount = amount.to_f * row[6].to_f
            total+=amount.to_f
          end

          if  ing.to_i == 17
            total = total - amount.to_f
            amount = amount.to_f * row[8].to_f
            total += amount.to_f
          end

          if  ing.to_i == 24
            total = total - amount.to_f
            amount = amount.to_f * row[8].to_f
            total += amount.to_f
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
      calculator = nil
      calculator = Dentaku::Calculator.new
      calculator.store(remuneracion_basica: rem_basic)
      calculator.store(precio_por_hora: por_hora)
      calculator.store(horas_trabajadas: row[7])
      calculator.store(horas_totales_semana: total_hour)
      calculator.store(dias_trabajados: worker_hours)
      calculator.store(horas_simples: row[9])
      calculator.store(horas_dobles: row[10])
      calculator.store(horas_extras_60: 0)
      calculator.store(horas_extras_100: 0)

      puts "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
      puts "descuentos"
      puts "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
      if !des.nil?
        des.each do |de|
          con = nil
          hash_formulas = Hash.new
          con = Concept.find(de)
          
          if !@result[0].include?(con.name)
            @result[0] << con.name.to_s
          end

          contract = Worker.find(row[0]).worker_contracts.where(:status => 1).first.worker_contract_details.where(:concept_id => de).first

          if !contract.nil?
            if contract.amount != 0 && !contract.amount.nil?
              amount = contract.amount.to_f
              total += amount.to_f
            else
              if con.concept_valorization.nil? && con.amount.to_f != 0.0
                amount = con.amount.to_f
                total += amount.to_f
              else
                amount = Formule.translate_formules(con.concept_valorization.formula, rem_basic, row[0], calculator, hash_formulas, con.token)
                if amount.to_f > con.top.to_f && de.to_i != 28 && de.to_i != 29 && de.to_i != 30 && de.to_i!=31
                  amount = con.top.to_f
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
                if con.concept_valorization.nil? && con.amount.to_f != 0.0
                  amount = con.amount.to_f
                  total += amount
                else
                  amount = Formule.translate_formules(con.concept_valorization.formula, rem_basic, row[0], calculator, hash_formulas, con.token)
                  if amount.to_f > con.top.to_f && de.to_i != 28 && de.to_i != 29 && de.to_i != 30 && de.to_i!=31
                    amount = con.top.to_f
                  end
                  total += amount.to_f
                end
              end
            else
              if con.concept_valorization.nil? && con.amount.to_f != 0.0
                amount = con.amount.to_f
                total += amount
              else
                amount = Formule.translate_formules(con.concept_valorization.formula, rem_basic, row[0], calculator, hash_formulas, con.token)
                if amount.to_f > con.top.to_f && de.to_i != 28 && de.to_i != 29 && de.to_i != 30 && de.to_i!=31
                  amount = con.top.to_f
                end              
                total += amount.to_f
              end
            end
          end
          afp = Afp.find(row[12]).afp_details.where("date_entry BETWEEN '"+week_start.to_s+"' AND '"+ week_end.to_s+"'").first
          if afp.nil?
            afp = Afp.find(row[12])
          end
          if  de.to_i == 28
            total = total - amount.to_f
            amount = amount.to_f * afp.contribution_fp.to_f/100
            if amount > afp.top
              amount = afp.top
            end
            total += amount.to_f
          end
          if  de.to_i == 29
            total = total - amount.to_f
            amount = amount.to_f * afp.insurance_premium.to_f/100
            if amount > afp.top
              amount = afp.top
            end          
            total += amount.to_f
          end
          if  de.to_i == 30
            total = total - amount.to_f
            amount = amount.to_f * afp.mixed.to_f/100
            if amount > afp.top
              amount = afp.top
            end          
            total +=amount.to_f
          end
          if de.to_i == 31
            total = total - amount.to_f
            amount = amount.to_f * afp.c_variable.to_f/100
            if amount > afp.top
              amount = afp.top
            end          
            total += amount.to_f
          end
          if de.to_i == 26
            total -=amount
            bruta = amount*14*4
            if bruta > uit
              amount = (bruta - uit)*0.15/12/4
            else
              amount = 0
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

      calculator = nil
      calculator = Dentaku::Calculator.new
      calculator.store(remuneracion_basica: rem_basic)
      calculator.store(precio_por_hora: por_hora)
      calculator.store(horas_trabajadas: row[7])
      calculator.store(horas_totales_semana: total_hour)
      calculator.store(dias_trabajados: worker_hours)
      calculator.store(horas_simples: row[9])
      calculator.store(horas_dobles: row[10])
      calculator.store(horas_extras_60: 0)
      calculator.store(horas_extras_100: 0)
      puts "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
      puts "Aportaciones"
      puts "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
      if !apo.nil?
        apo.each do |ap|
          hash_formulas = Hash.new
          con = Concept.find(ap)
          if !apoNa.include?(con.name)
            @result[0] << con.name.to_s
            apoNa << con.name.to_s
          end
          if con.concept_valorization.nil? && con.amount.to_f != 0.0
            amount = con.amount.to_f
            total += amount
            @result[@i] << amount
          else
            amount = Formule.translate_formules(con.concept_valorization.formula, rem_basic, row[0], calculator, hash_formulas, con.token)
            total += amount.to_f
            @result[@i] << amount
          end
        end
        @result[@i] << total

        if !@result[0].include?("Aportaciones Totales")
          @result[0] << "Aportaciones Totales"
        end
      end
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
