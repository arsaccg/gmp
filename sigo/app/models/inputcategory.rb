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
            ActiveRecord::Base.connection.execute(query_str_sale).each { |item| hash_categories_sale[item[0] + item[2]] = item }
            ActiveRecord::Base.connection.execute(query_str_goal).each { |item| hash_categories_goal[item[0] + item[2]] = item }
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
      str_query = "SELECT  inputs.input ,inputs.cod_input, SUM(inputs.quantity * inputs.price * itembybudgets.measured)
                FROM itembybudgets,
                     (
                     SELECT quantity, price, `order`, item_id, cod_input, budget_id, input
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

    def self.build_query_phases(budgetid)
        # str = "SELECT T1.wbscode, T1.fase,  CONCAT('0', T1.category_id) as category_id, T1.description,  SUM(T1.amount) AS amount_sale
        #             FROM (
        #                     SELECT itembywbses.wbscode,category_id, wbsitems.fase, inputcategories.description, itembybudgets.item_id,itembybudgets.`order` AS item_order ,SUM(inputbybudgetanditems.price*inputbybudgetanditems.quantity*itembywbses.measured) AS amount
        #                     FROM inputcategories, inputbybudgetanditems, itembybudgets
        #                     RIGHT JOIN  itembywbses ON
        #                                 itembywbses.item_id = itembybudgets.item_id AND
        #                                 itembywbses.order_budget = itembybudgets.`order` 
        #                     LEFT JOIN   wbsitems ON
        #                                 itembywbses.wbsitem_id = wbsitems.id
        #                     WHERE inputbybudgetanditems.cod_input LIKE CONCAT('0', CONCAT(category_id, '%'))  AND
        #                           inputbybudgetanditems.budget_id = '" + budgetid + "' AND
        #                           inputbybudgetanditems.item_id=itembybudgets.item_id AND
        #                           inputbybudgetanditems.budget_id = itembybudgets.budget_id AND
        #                           inputbybudgetanditems.`order` = itembybudgets.`order` 
        #                     GROUP BY category_id, itembybudgets.item_id
        #                     ORDER BY category_id 
        #                 ) AS T1, itembybudgets
                      
        #             WHERE itembybudgets.item_id =  T1.item_id AND
        #                   itembybudgets.`order` =  T1.item_order 
                            
        #             GROUP BY T1.wbscode, category_id
        #             ORDER BY category_id;"
        str = "SELECT T1.wbscode, T1.fase, CONCAT('0', T1.category_id) as category_id, T1.description, 
                SUM(T1.amount) AS amount_sale, T1.coditem,T1.item_order,T1.measured
               FROM inputcategories, (
                SELECT itembywbses.wbscode, category_id, wbsitems.fase, inputcategories.description, 
                  itembybudgets.item_id, itembybudgets.`order` AS item_order, 
                  SUM(ROUND(inputbybudgetanditems.price*ROUND(inputbybudgetanditems.quantity*itembywbses.measured, 2),2) AS amount, 
                  inputbybudgetanditems.coditem, itembywbses.measured
                 FROM inputbybudgetanditems, itembybudgets
                 RIGHT JOIN itembywbses ON
                 itembywbses.coditem = itembybudgets.item_code AND
                 itembywbses.order_budget = itembybudgets.`order` AND
                 itembywbses.budget_id = '" + budgetid.to_s  + "'
                 LEFT JOIN wbsitems ON
                 itembywbses.wbsitem_id = wbsitems.id
                 WHERE
                 inputbybudgetanditems.cod_input LIKE CONCAT('0', CONCAT(category_id, '%'))  AND
                 inputbybudgetanditems.budget_id = '" + budgetid.to_s  + "' AND
                 inputbybudgetanditems.coditem=itembybudgets.item_code AND
                 inputbybudgetanditems.budget_id = itembybudgets.budget_id AND
                 inputbybudgetanditems.`order` = itembybudgets.`order` 
                 GROUP BY category_id, itembybudgets.item_id
                   ORDER BY category_id
               ) AS T1, itembybudgets
               
               WHERE itembybudgets.item_id = T1.item_id AND
               itembybudgets.`order` = T1.item_order 
               
               GROUP BY T1.wbscode, category_id
               ORDER BY category_id;"
        return str 
    end
    
end
