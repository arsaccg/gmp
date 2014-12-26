class Formule < ActiveRecord::Base

  def self.translate_formules(formula, basico, worker_id, calculator, hash_formulas, main_concept, twid, concept_id = nil)
    main = main_concept.tr('][', '').gsub('-','_')
    #p ' FORMULA INGRESADA '
    #p formula
    #p ' FORMULA INGRESADA '
    const_variables = formula.scan(/\[.*?\]/).delete_if {|i| i == "[remuneracion-basica]" }
    if !concept_id.nil? # => Esto Indica que el Token Generico existe
      # hash_formulas[main.to_sym] = formula.tr('][', '').gsub('-','_')
      # => Token Generico
      amount_generic_from_contract = Worker.find(worker_id).worker_contracts.where(:status => 1).first.worker_contract_details.where(:concept_id => concept_id).first
      if amount_generic_from_contract.nil?
        mov_article_id = Worker.find(worker_id).worker_contracts.where(:status => 1).first.article_id
        @mov_category_id = Category.find_by_code(Article.find(mov_article_id).code[2..5]).id
        amount_generic_from_category = CategoryOfWorker.find_by_category_id(@mov_category_id).category_of_workers_concepts.where(:concept_id => concept_id).first
        if amount_generic_from_category.nil?
          calculator.store(monto_contrato_categoria: 0)
        else
          calculator.store(monto_contrato_categoria: amount_generic_from_category.amount.to_f)
        end
      else
        calculator.store(monto_contrato_categoria: amount_generic_from_contract.amount.to_f)
      end

      const_variables = formula.scan(/\[.*?\]/).delete_if {|i| i == "[monto-contrato-categoria]" }.delete_if {|i| i == "[remuneracion-basica]" }
      const_variables.each do |c|
        concept = Concept.find_by_token(c)
        if !concept.nil?
          formu = concept.concept_valorizations
          contract = Worker.find(worker_id).worker_contracts.where(:status => 1).first.worker_contract_details.where(:concept_id => concept.id).first
          amount = 0
          if !contract.nil?
            if contract.amount != 0 && !contract.amount.nil?
              amount = contract.amount.to_f
            else
              if formu.nil? && concept.amount.to_f != 0.0
                amount = concept.amount.to_f
              elsif formu.formula != ''
                f_final = formu.formula # => Formula del concepto /c/
                formula = formula.gsub(c, f_final)
              end
            end
          else
            article_id = Worker.find(worker_id).worker_contracts.where(:status => 1).where(:status => 1).first.article_id
            category_id = Category.find_by_code(Article.find(article_id).code[2..5]).id
            from_category = CategoryOfWorker.find_by_category_id(category_id).category_of_workers_concepts.where(:concept_id => concept.id).first
            if !from_category.nil?
              if from_category.amount.to_f != 0.0 && !from_category.amount.nil?
                amount = from_category.amount
              else
                if !formu.nil? && concept.amount.to_f != 0.0
                  amount = concept.amount.to_f
                elsif formu.formula != ''
                  f_final = formu.formula # => Formula del concepto /c/
                  formula = formula.gsub(c, f_final)
                end
              end
            else
              if !formu.nil? && concept.amount.to_f != 0.0
                amount = concept.amount.to_f
              elsif formu.formula != ''
                f_final = formu.formula # => Formula del concepto /c/
                formula = formula.gsub(c, f_final)
              end
            end
          end
          var = concept.token.tr('][', '').gsub('-','_')
          calculator.store(var.to_sym => amount.to_f)
        end
      end
    else
      const_variables.each do |c|
        concept = Concept.find_by_token(c)
        if !concept.nil?
          formu = concept.concept_valorizations.where("type_worker = "+twid.to_s).first
          contract = Worker.find(worker_id).worker_contracts.where(:status => 1).first.worker_contract_details.where(:concept_id => concept.id).first
          amount = 0
          if !contract.nil?
            if contract.amount != 0 && !contract.amount.nil?
              amount = contract.amount.to_f
            else
              if formu.nil? && concept.amount.to_f != 0.0
                amount = concept.amount.to_f
              elsif formu.formula != ''
                f_final = formu.formula # => Formula del concepto /c/
                formula = formula.gsub(c, f_final)
              end
            end
          else
            article_id = Worker.find(worker_id).worker_contracts.where(:status => 1).where(:status => 1).first.article_id
            category_id = Category.find_by_code(Article.find(article_id).code[2..5]).id
            from_category = CategoryOfWorker.find_by_category_id(category_id).category_of_workers_concepts.where(:concept_id => concept.id).first
            if !from_category.nil?
              if from_category.amount.to_f != 0.0 && !from_category.amount.nil?
                amount = from_category.amount
              else
                if !formu.nil? && concept.amount.to_f != 0.0
                  amount = concept.amount.to_f
                elsif formu.formula != ''
                  f_final = formu.formula # => Formula del concepto /c/
                  formula = formula.gsub(c, f_final)
                end
              end
            else
              if !formu.nil? && concept.amount.to_f != 0.0
                amount = concept.amount.to_f
              elsif formu.formula != ''
                f_final = formu.formula # => Formula del concepto /c/
                formula = formula.gsub(c, f_final)
              end
            end
          end
          var = concept.token.tr('][', '').gsub('-','_')
          calculator.store(var.to_sym => amount.to_f)
        end
      end
    end

    f_s= formula
    formula.scan(/\[.*?\]/).each do |a|
      c = a.tr('][', '').gsub('-','_')
      f_s = f_s.to_s.gsub(a,c)
    end

    hash_formulas[main.to_sym] = f_s
    
    #p ' FORMULA!!! '
    #p calculator.inspect
    #p main_concept
    #p formula
    #p calculator.solve!(hash_formulas).values[0].to_f
    #p ' FORMULA!!! '
    return calculator.solve!(hash_formulas).values[0].to_f
  end

  def self.translate_formules_of_employee(formula, basico, worker_id, calculator, hash_formulas, main_concept, twid)
    main = main_concept.tr('][', '').gsub('-','_')
    #p ' FORMULA INGRESADA '
    #p formula
    #p ' FORMULA INGRESADA '
    const_variables = formula.scan(/\[.*?\]/).delete_if {|i| i == "[remuneracion-basica]" }

    const_variables.each do |c|
      concept = Concept.find_by_token(c)
      if !concept.nil?
        formu = concept.concept_valorizations.where("type_worker = "+twid.to_s).first
        if formu.nil? && concept.amount.to_f != 0.0
          amount = concept.amount.to_f
        elsif formu.formula != ''
          f_final = formu.formula # => Formula del concepto /c/
          formula = formula.gsub(c, f_final)
        end
        var = concept.token.tr('][', '').gsub('-','_')
        calculator.store(var.to_sym => amount.to_f)
      end
    end
    f_s= formula
    formula.scan(/\[.*?\]/).each do |a|
      c = a.tr('][', '').gsub('-','_')
      f_s = f_s.to_s.gsub(a,c)
    end

    hash_formulas[main.to_sym] = f_s

    #p ' FORMULA!!! '
    #p calculator.inspect
    #p main_concept
    #p formula
    #p calculator.solve!(hash_formulas).values[0].to_f
    #p ' FORMULA!!! '
    return calculator.solve!(hash_formulas).values[0].to_f
  end
end