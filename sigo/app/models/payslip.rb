class Payslip < ActiveRecord::Base

  def self.generate_payroll_workers cost_center_id, week_id, week_start, week_end
    result = Array.new
    total_hour = WeeksPerCostCenter.get_total_hours_per_week(cost_center_id, week_id)
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
      # Remuneracion Básica
      rem_basic = 0
      from_contract = Worker.find(row[0]).worker_contracts.where(:status => 1).first.worker_contract_details.where(:concept_id => 1).first
      if !from_contract.nil?
        if from_contract.amount != 0
          rem_basic = (from_contract.amount/8)*row[7]
        else
          article_id = Worker.find(row[0]).worker_contracts.where(:status => 1).first.article_id
          category_id = Category.find_by_code(Article.find(article_id).code[2..5]).id
          from_category = CategoryOfWorker.find_by_category_id(category_id).category_of_workers_concepts.where(:concept_id => 1).first
          if from_category.amount != 0
            rem_basic = (from_category.amount.to_f/8)*row[7]
          end
        end
      else
        article_id = Worker.find(row[0]).worker_contracts.where(:status => 1).first.article_id
        category_id = Category.find_by_code(Article.find(article_id).code[2..5]).id
        from_category = CategoryOfWorker.find_by_category_id(category_id).category_of_workers_concepts.where(:concept_id => 1).first
        if from_category.amount != 0
          rem_basic = (from_category.amount.to_f/8)*row[7]
        end
      end

      dominicano = rem_basic/6 # Dominical 1/6
      cts = Concept.find(13).percentage.to_f/100 * rem_basic # % CTS - Data Static

      # Viaticos
      viaticos = 0
      from_contract_viatico = Worker.find(row[0]).worker_contracts.where(:status => 1).first.worker_contract_details.where(:concept_id => 14).first
      if !from_contract_viatico.nil?
        if from_contract_viatico.amount != 0
          viaticos = from_contract_viatico.amount.to_f
        end
      else
        article_id = Worker.find(row[0]).worker_contracts.where(:status => 1).first.article_id
        category_id = Category.find_by_code(Article.find(article_id).code[2..5]).id
        from_category_viatico = CategoryOfWorker.find_by_category_id(category_id).category_of_workers_concepts.where(:concept_id => 14).first
        if from_category_viatico.amount != 0
          viaticos = from_category_viatico.amount.to_f
        end
      end

      # Asignacion Escolar
      asign_escolar = 0
      from_contract_asign_escolar = Worker.find(row[0]).worker_contracts.where(:status => 1).first.worker_contract_details.where(:concept_id => 15).first
      if !from_contract_asign_escolar.nil?
        if from_contract_asign_escolar.amount != 0
          asign_escolar = from_contract_asign_escolar.amount.to_f
        end
      else
        article_id = Worker.find(row[0]).worker_contracts.where(:status => 1).first.article_id
        category_id = Category.find_by_code(Article.find(article_id).code[2..5]).id
        from_category_asign_escolar = CategoryOfWorker.find_by_category_id(category_id).category_of_workers_concepts.where(:concept_id => 15).first
        if from_category_asign_escolar.amount != 0
          asign_escolar = from_category_asign_escolar.amount.to_f
        end
      end

      result << [ row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], rem_basic, dominicano, cts, viaticos, asign_escolar ]
    end

    return result
  end
end
