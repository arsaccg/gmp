class Formule < ActiveRecord::Base

  def self.translate_formules(formula,basico,worker_id)
    str_sentence = formula
    puts "-------------------------------------------str_sentence 1-------------------------------------------------------------------------"
    puts str_sentence
    puts "----------------------------------------------------------------------------------------------------------------------------------"
    const_variables = formula.scan(/\[.*?\]/)
    puts "---------------------------------------------const_variables----------------------------------------------------------------------"
    puts const_variables
    puts "---------------------------------------------const_variables----------------------------------------------------------------------"
    const_variables.each do |c|
      concept = Concept.find_by_token(c)
      puts "--------------------------------------concept---------------------------"
      puts c
      puts "........................................................................."
      if concept.id != 1
        contract = Worker.find(worker_id).worker_contracts.where(:status => 1).first.worker_contract_details.where(:concept_id => concept.id).first
        amount = 0
        if !contract.nil?
          if contract.amount != 0 && !contract.amount.nil?
            amount = contract.amount.to_f
          else
            formula = concept.concept_valorization
            if formula.nil?
              amount = concept.amount.to_f
            else
              formula = formula.formula 
              amount = Formule.translate_formules(formula, basico,worker_id)
            end
          end
        else
          article_id = Worker.find(worker_id).worker_contracts.where(:status => 1).where(:status => 1).first.article_id
          category_id = Category.find_by_code(Article.find(article_id).code[2..5]).id
          from_category = CategoryOfWorker.find_by_category_id(category_id).category_of_workers_concepts.where(:concept_id => concept.id).first
          if !from_category.nil?
            if from_category.amount != 0.0 && !from_category.amount.nil?
              amount = from_category.amount
            else
              formula = concept.concept_valorization.formula
              amount = Formule.translate_formules(formula, basico,worker_id)
            end
          else
            formula = concept.concept_valorization
            if formula.nil?
              amount = concept.amount.to_f
            else
              formula = formula.formula 
              amount = Formule.translate_formules(formula, basico,worker_id)
            end
          end
        end
        puts "-----------------------------------amount--------------------------------------------"
        puts amount
        puts "-------------------------------------...........................----------------------"
        str_sentence.gsub! c, amount.to_s
        puts "........................................str_sentence...................................."
        puts str_sentence
        puts "....................................................................................."
      else
        str_sentence.gsub! c, basico.to_s
      end
    end
    puts "---------------------------------------------str_sentence 2-----------------------------------------------------------------------"
    puts str_sentence
    puts "----------------------------------------------------------------------------------------------------------------------------------"
    return eval(str_sentence.to_s)
  end

end
