class Inputcategory < ActiveRecord::Base
 

    def self.sum_partial_sales(budgetid_sale, budgetid_goal, wbs=nil)
         
        hash_categories_sale, hash_categories_goal = Hash.new, Hash.new
        query_str_sale, query_str_goal = nil, nil

        if wbs == nil
            query_str_sale, query_str_goal = Inputcategory.build_query_sum(budgetid_sale), Inputcategory.build_query_sum(budgetid_goal)
            ActiveRecord::Base.connection.execute(query_str_sale).each { |item| hash_categories_sale[item[0]] = item }
            ActiveRecord::Base.connection.execute(query_str_goal).each { |item| hash_categories_goal[item[0]] = item }
        else
            query_str_sale, query_str_goal = Inputcategory.build_query_phases(budgetid_sale), Inputcategory.build_query_phases(budgetid_goal)
            # query_str_sale, query_str_goal = Inputcategory.build_query_phases(wbs, budgetid_sale), Inputcategory.build_query_phases(wbs, budgetid_goal)
            ActiveRecord::Base.connection.execute(query_str_sale).each { |item| hash_categories_sale[item[0].to_s + '_' + item[2].to_s] = item } #codigo + categoria
            ActiveRecord::Base.connection.execute(query_str_goal).each { |item| hash_categories_goal[item[0].to_s + '_' + item[2].to_s] = item }
        end

        return hash_categories_sale, hash_categories_goal
    end

    def self.build_query_sum(budgetid)
        str = "SELECT CONCAT('0', inputcategories.category_id) as category_id, inputcategories.description, SUM(ROUND(ROUND(items.price * items.quantity, 2) * items.measured, 4))
                  FROM inputcategories,
                  (
                    SELECT  inputs.cod_input, inputs.quantity, inputs.price, itembybudgets.measured, inputs.item_id, inputs.`order`
                      FROM itembybudgets,
                      (
                        SELECT quantity, price, `order`, item_id, cod_input, budget_id
                          FROM inputbybudgetanditems
                      ) AS inputs
                      WHERE inputs.item_id = itembybudgets.item_id AND
                          inputs.`order` = itembybudgets.`order` AND
                          inputs.budget_id = itembybudgets.budget_id AND
                          itembybudgets.budget_id = '" + budgetid.to_s + "'
                  ) AS items
                  WHERE items.cod_input LIKE CONCAT('0', CONCAT(category_id, '%'))
                  GROUP BY category_id
              ORDER BY category_id"
        return str
    end

    def self.get_inputs(budget_id, category_prefix)
      hash_inputs = Hash.new
      str_query = "SELECT  inputs.input ,inputs.cod_input, inputs.unit, SUM(inputs.quantity * inputs.price * itembybudgets.measured)
                FROM itembybudgets,
                     (
                     SELECT quantity, price, `order`, item_id, cod_input, budget_id, input, unit
                     FROM inputbybudgetanditems
                     ) AS inputs

                WHERE inputs.`order` = itembybudgets.`order` AND
                  inputs.budget_id = itembybudgets.budget_id AND
                  itembybudgets.budget_id = '" + budget_id.to_s  + "' AND
                  inputs.cod_input LIKE '" + category_prefix.to_s + "%'
                GROUP BY inputs.cod_input	ORDER BY inputs.input"
      ActiveRecord::Base.connection.execute(str_query).each { |item| hash_inputs[item[1]] =  item }
      return hash_inputs
    end

    def self.get_inputs_wbs(budget_id, codewbs, category_prefix)
      hash_inputs = Hash.new
      str_query = "SELECT ibi.input, ibi.cod_input, ibi.unit, sum(ibi.amount) as amount_t, ibi.cod_input from (
                  SELECT `inputbybudgetanditems`.input, `inputbybudgetanditems`.cod_input, `inputbybudgetanditems`.unit, ( `inputbybudgetanditems`.price * `inputbybudgetanditems`.quantity * `itembybudgets`.measured ) as amount
                  FROM `wbsitems` , `itembywbses` , `inputbybudgetanditems` , `itembybudgets`
                  WHERE `itembywbses`.wbscode = `wbsitems`.codewbs
                  AND `itembywbses`.budget_id ="+budget_id.to_s+"
                  AND `inputbybudgetanditems`.`order` = `itembywbses`.order_budget
                  AND `inputbybudgetanditems`.coditem = `itembywbses`.coditem
                  AND `inputbybudgetanditems`.budget_id ="+budget_id.to_s+"
                  and `wbsitems`.codewbs = "+codewbs.to_s+"
                  AND `inputbybudgetanditems`.cod_input like '0"+category_prefix.to_s+"%'
                  AND `itembybudgets`.budget_id ="+budget_id.to_s+"
                  AND  `itembybudgets`.item_code =  `itembywbses`.coditem
                  AND  `itembybudgets`.`order` =  `itembywbses`.order_budget
                  GROUP by  `inputbybudgetanditems`.id
                  ORDER BY  `inputbybudgetanditems`.cod_input) as ibi
                  GROUP by  ibi.cod_input"
      ActiveRecord::Base.connection.execute(str_query).each { |item| hash_inputs[item[1]] =  item }
      return hash_inputs
    end

    def self.build_query_phases(budgetid)
          str = "SELECT  `wbsitems`.codewbs, `wbsitems`.id, `inputcategories`.category_id, `inputcategories`.description, SUM(  `inputbybudgetanditems`.price * `inputbybudgetanditems`.quantity *  `itembybudgets`.measured ) as amount, `itembywbses`.coditem, `itembywbses`.order_budget, `itembybudgets`.measured
                FROM  `wbsitems` ,  `itembywbses` ,  `inputbybudgetanditems` ,  `itembybudgets` ,  `inputcategories` 
                WHERE  `itembywbses`.wbscode =  `wbsitems`.codewbs
                AND `itembywbses`.budget_id ="+budgetid.to_s+"
                AND  `inputbybudgetanditems`.`order` =  `itembywbses`.order_budget
                AND  `inputbybudgetanditems`.coditem =  `itembywbses`.coditem
                AND  `inputbybudgetanditems`.budget_id ="+budgetid.to_s+"
                AND  `inputcategories`.level_n <2 
                AND  `inputbybudgetanditems`.cod_input LIKE CONCAT(  '0', CONCAT(  `inputcategories`.category_id,  '%' ) ) 
                AND  `itembybudgets`.budget_id ="+budgetid.to_s+"
                AND  `itembybudgets`.item_code =  `itembywbses`.coditem
                AND  `itembybudgets`.`order` =  `itembywbses`.order_budget
                GROUP BY  `wbsitems`.codewbs,  `inputcategories`.category_id
                ORDER BY  `wbsitems`.codewbs, CONCAT(  `inputcategories`.category_id,  '' ) "
        return str 
    end



    
end
