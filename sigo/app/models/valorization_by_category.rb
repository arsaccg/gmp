class ValorizationByCategory < ActiveRecord::Base


    def self.sum_valorization_sales_total(budgetid, valorization_id)
      hash_categories_sale, hash_categories_goal = Hash.new, Hash.new
      query_str_sale, query_str_goal = nil, nil

      query_str_sale = ValorizationByCategory.build_query_sum_with_valorization_total(budgetid, valorization_id)
      ActiveRecord::Base.connection.execute(query_str_sale).each { |item| hash_categories_sale[item[0]] = item }
      #ActiveRecord::Base.connection.execute(query_str_goal).each { |item| hash_categories_goal[item[0]] = item }

      return hash_categories_sale#, hash_categories_goal
    end

    def self.build_query_sum_with_valorization_total(budgetid, valorization_id)
        str = "SELECT CONCAT('0', inputcategories.category_id) as category_id, inputcategories.description, SUM(ROUND(ROUND(items.price * items.quantity, 2) * items.acc_measured, 4))
              FROM 
			  (
			    SELECT  *
			      FROM inputcategories
			      WHERE category_id < 100
			  ) AS inputcategories,
              (
                SELECT  inputs.cod_input, inputs.quantity, inputs.price, report_valorizations.acc_measured, inputs.item_id, inputs.`order`
                  FROM itembybudgets, report_valorizations,
                  (
                    SELECT quantity, price, `order`, item_id, cod_input, budget_id
                      FROM inputbybudgetanditems
                  ) AS inputs
                  WHERE inputs.item_id = itembybudgets.item_id AND
                      inputs.`order` = itembybudgets.`order` AND
                      inputs.budget_id = itembybudgets.budget_id AND
                      itembybudgets.budget_id = "+budgetid.to_s+" AND
                report_valorizations.valorization_id = "+valorization_id.to_s+" AND
                report_valorizations.`order` = itembybudgets.`order`
                
              ) AS items
              WHERE items.cod_input LIKE CONCAT('0', CONCAT(category_id, '%'))
              AND category_id NOT LIKE '%__'
              GROUP BY category_id
              ORDER BY category_id"
        return str
    end

    def self.sum_valorization_sales(budgetid, valorization_id)
      hash_categories_sale, hash_categories_goal = Hash.new, Hash.new
      query_str_sale, query_str_goal = nil, nil

      query_str_sale = Inputcategory.build_query_sum_with_valorization(budgetid, valorization_id)
      ActiveRecord::Base.connection.execute(query_str_sale).each { |item| hash_categories_sale[item[0]] = item }
      #ActiveRecord::Base.connection.execute(query_str_goal).each { |item| hash_categories_goal[item[0]] = item }

      return hash_categories_sale#, hash_categories_goal
    end

    def self.build_query_sum_with_valorization(budgetid, valorization_id)
        str = "SELECT CONCAT('0', inputcategories.category_id) as category_id, inputcategories.description, SUM(ROUND(ROUND(items.price * items.quantity, 2) * items.acc_measured, 4))
              FROM inputcategories,
              (
                SELECT  inputs.cod_input, inputs.quantity, inputs.price, report_valorizations.acc_measured, inputs.item_id, inputs.`order`
                  FROM itembybudgets, report_valorizations,
                  (
                    SELECT quantity, price, `order`, item_id, cod_input, budget_id
                      FROM inputbybudgetanditems
                  ) AS inputs
                  WHERE inputs.item_id = itembybudgets.item_id AND
                      inputs.`order` = itembybudgets.`order` AND
                      inputs.budget_id = itembybudgets.budget_id AND
                      itembybudgets.budget_id = "+budgetid.to_s+" AND
                report_valorizations.valorization_id = "+valorization_id.to_s+" AND
                report_valorizations.`order` = itembybudgets.`order`
                
              ) AS items
              WHERE items.cod_input LIKE CONCAT('0', CONCAT(category_id, '%'))
              GROUP BY category_id
              ORDER BY category_id"
        return str
    end

end
