class Payslip < ActiveRecord::Base

  def self.generate_payroll_workers cost_center_id, week_id, week_start, week_end, ing, des, headers
    @result = Array.new
    total_hour = WeeksPerCostCenter.get_total_hours_per_week(cost_center_id, week_id)
    @i = 1
    @result[0] = headers
    @result[0] << "REMUNERACIÓN BÁSICA"
    @result[0] << "HORAS EXTRAS 60%"
    @result[0] << "HORAS EXTRAS 100%"
    @result[0] << "ASIGNACIÓN ESCOLAR"
    @result[0] << "MOVILIDAD"
    @result[0] << "BUC"
    amount = 0
    ActiveRecord::Base.connection.execute("
      SELECT ppd.worker_id, e.dni, CONCAT_WS(' ', e.name, e.second_name, e.paternal_surname, e.maternal_surname), ar.name, pp.date_of_creation, af.type_of_afp, w.numberofchilds, SUM( ppd.normal_hours ) , SUM( 1 ) AS Dias, SUM( ppd.he_60 ) , SUM( ppd.he_100 ) , SUM( ppd.total_hours ) 
      FROM part_people pp, part_person_details ppd, entities e, workers w, worker_afps wa, afps af, worker_contracts wc, articles ar
      WHERE pp.cost_center_id = " + cost_center_id.to_s + "
      AND ppd.part_person_id = pp.id
      AND pp.date_of_creation BETWEEN '" + week_start.to_s + "' AND  '" + week_end.to_s + "'
      AND ppd.worker_id = w.id
      AND w.entity_id = e.id
      AND wa.worker_id = w.id
      AND af.id = wa.afp_id
      AND wc.worker_id = w.id
      AND wc.article_id = ar.id
      GROUP BY ppd.worker_id
    ").each do |row|
      @result << [ row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10] ]

      amount = 0
      # Remuneracion Básica
      rem_basic = 0
      total = 0
      por_hora = 0
      from_contract = Worker.find(row[0]).worker_contracts.where(:status => 1).first.worker_contract_details.where(:concept_id => 1).first
      if !from_contract.nil?
        if !from_contract.amount.nil?
          rem_basic = (from_contract.amount/48)*row[7]
          por_hora = from_contract.amount.to_f/48
        else
          article_id = Worker.find(row[0]).worker_contracts.where(:status => 1).first.article_id
          category_id = Category.find_by_code(Article.find(article_id).code[2..5]).id
          from_category = CategoryOfWorker.find_by_category_id(category_id).category_of_workers_concepts.where(:concept_id => 1).first
          asig = CategoryOfWorker.find_by_category_id(category_id).category_of_workers_concepts.where(:concept_id => 15).first
          mov = CategoryOfWorker.find_by_category_id(category_id).category_of_workers_concepts.where(:concept_id => 17).first
          buc = CategoryOfWorker.find_by_category_id(category_id).category_of_workers_concepts.where(:concept_id => 24).first
          if from_category.amount != 0
            rem_basic = (from_category.amount.to_f/48)*row[7]
            por_hora = from_category.amount.to_f/48
          end
        end
      else
        article_id = Worker.find(row[0]).worker_contracts.where(:status => 1).first.article_id
        category_id = Category.find_by_code(Article.find(article_id).code[2..5]).id
        from_category = CategoryOfWorker.find_by_category_id(category_id).category_of_workers_concepts.where(:concept_id => 1).first
        asig = CategoryOfWorker.find_by_category_id(category_id).category_of_workers_concepts.where(:concept_id => 15).first
        mov = CategoryOfWorker.find_by_category_id(category_id).category_of_workers_concepts.where(:concept_id => 17).first
        buc = CategoryOfWorker.find_by_category_id(category_id).category_of_workers_concepts.where(:concept_id => 24).first        
        if from_category.amount != 0
          rem_basic = (from_category.amount.to_f/48)*row[7]
          por_hora = from_category.amount.to_f/48
        end
      end
      @result[@i] << rem_basic
      @result[@i] << row[9]*por_hora*1.6
      @result[@i] << row[10]*por_hora*2
      @result[@i] << asig.amount * row[6].to_f
      @result[@i] << mov.amount * row[8].to_f
      @result[@i] << buc.amount * row[8].to_f
      
      total += rem_basic + row[9]*por_hora*1.6 + row[10]*por_hora*2
      ing.each do |ing|
        puts "´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´´"
        con = nil
        formu = nil
        con = Concept.find(ing)
        if con.id != 1 && con.id != 4 && con.id != 5 && con.id != 15 && con.id != 17 && con.id != 24
          formu = con.concept_valorization
          puts con.inspect
          puts formu.inspect
          puts "-                                                     ---                                                                      -"
          if !@result[0].include?(con.name)
            @result[0] << con.name.to_s
          end
          contract = Worker.find(row[0]).worker_contracts.where(:status => 1).first.worker_contract_details.where(:concept_id => ing).first

          if !contract.nil?
            if contract.amount != 0 && !contract.amount.nil?
              amount = contract.amount.to_f
              total += amount
            else
              if formu.nil? && con.amount.to_f != 0.0
                amount = con.amount.to_f
                total += amount
              else
                puts "----------------------------------00----------------------------------------------------"
                puts rem_basic
                puts formu.formula
                puts "------------------------------------00--------------------------------------------------"
                amount = Formule.translate_formules(formu.formula, rem_basic,row[0])
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
                if formu.nil? && con.amount.to_f != 0.0
                  amount = con.amount.to_f
                  total += amount
                else
                  puts "----------------------------------01----------------------------------------------------"
                  puts rem_basic
                  puts formu.formula
                  puts "------------------------------------01--------------------------------------------------"                  
                  amount = Formule.translate_formules(formu.formula, rem_basic,row[0])
                  total += amount
                end
              end
            else
              if formu.nil? && con.amount.to_f != 0.0
                amount = con.amount.to_f
                total += amount
              else
                puts "----------------------------------02----------------------------------------------------"
                puts rem_basic
                puts formu.formula 
                puts "------------------------------------02--------------------------------------------------"                
                amount = Formule.translate_formules(formu.formula , rem_basic,row[0])
                total += amount
              end
            end
          end
          @result[@i] << amount
        end
      end
      @result[@i] << total

      @i+=1
      amount = 0
    end
    @result[0] << "Ingresos Totales"
    return @result
  end
end
