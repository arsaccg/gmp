class Formule < ActiveRecord::Base

  def self.translate_formules(formula,basico,worker_id, calculator, hash_formulas, main_concept)
    main = main_concept.tr('][', '').gsub('-','_')

    hash_formulas[main.to_sym] = formula.tr('][', '').gsub('-','_')
    const_variables = formula.scan(/\[.*?\]/)

    const_variables.each do |c|
      concept = Concept.find_by_token(c)
      if !concept.nil?
        formu = concept.concept_valorization
        if concept.id != 1 
          contract = Worker.find(worker_id).worker_contracts.where(:status => 1).first.worker_contract_details.where(:concept_id => concept.id).first
          amount = 0
          p '.................'
          p formula
          p concept.name
          p concept.id
          p contract
          p '.................'
          if !contract.nil?
            if contract.amount != 0 && !contract.amount.nil?
              amount = contract.amount.to_f
            else
              if formu.nil? && concept.amount.to_f != 0.0
                amount = concept.amount.to_f
              elsif formu.formula != ''
                amount = Formule.translate_formules(formu.formula, basico, worker_id, calculator, hash_formulas, concept.token)
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
                if formu.nil? && concept.amount.to_f != 0.0
                  amount = concept.amount.to_f
                elsif formu.formula != ''
                  amount = Formule.translate_formules(formu.formula, basico, worker_id, calculator, hash_formulas, concept.token)
                end
              end
            else
              if formu.nil? && concept.amount.to_f != 0.0
                amount = concept.amount.to_f
              elsif formu.formula != ''
                amount = Formule.translate_formules(formu.formula, basico, worker_id, calculator, hash_formulas, concept.token)
              end
            end
          end
          var = concept.token.tr('][', '').gsub('-','_')
          calculator.store(var: amount)
        end
      end
    end

    return calculator.solve!(hash_formulas).first[1]

  end
end