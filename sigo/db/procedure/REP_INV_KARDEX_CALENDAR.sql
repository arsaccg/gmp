CREATE PROCEDURE REP_INV_KARDEX_CALENDAR
(IN p_company INT, IN p_update_filter INT, IN p_report_type INT, IN p_kardex_type INT, IN p_user_id INT, IN p_from_date DATE, IN p_to_date DATE, IN p_cost_centers VARCHAR(500), IN p_warehouses VARCHAR(500), IN p_suppliers VARCHAR(500), IN p_responsibles VARCHAR(500), IN p_years VARCHAR(500), IN p_periods VARCHAR(500), IN p_formats VARCHAR(500), IN p_articles VARCHAR(500), IN p_moneys VARCHAR(500))
BEGIN

DECLARE v_finished INTEGER DEFAULT FALSE;
declare v_input, v_warehouse_id, v_period, v_article_id, v_year INTEGER;
declare v_warehouse_name, v_article_code, v_article_name, v_article_symbol VARCHAR(256);
declare v_issue_date DATE;
declare v_i_amount, v_i_unit_cost, v_i_total_cost, v_o_amount, v_o_unit_cost, v_o_total_cost DECIMAL(18,4);

DEClARE cur_RepInvSummary CURSOR FOR 
      SELECT warehouse_id, warehouse_name, article_id, article_code, article_name, article_symbol, SUM(Case When input = 1 Then Amount Else 0 End) As I, Coalesce(SUM(Case When input = 1 Then Amount * Unit_Cost Else null End), 0) As i_TC, Coalesce(SUM(Case When input = 0 Then Amount Else 0 End), 0) As o_aomunt, Coalesce(SUM(Case When input = 0 Then Amount * Unit_Cost Else null End), 0) As o_TC
	FROM	 TmpRepInv
	GROUP BY warehouse_id, warehouse_name, article_id, article_code, article_name, article_symbol;
DEClARE cur_RepInvDaily CURSOR FOR 
      SELECT warehouse_id, warehouse_name, year, period, issue_date, article_id, article_code, article_name, article_symbol, SUM(Case When input = 1 Then Amount Else 0 End) As I, Coalesce(SUM(Case When input = 1 Then Amount * Unit_Cost Else null End), 0) As i_TC, SUM(Case When input = 0 Then Amount Else 0 End) As o_aomunt, Coalesce(SUM(Case When input = 0 Then Amount * Unit_Cost Else null End), 0) As o_TC
	FROM	 TmpRepInv
	GROUP BY warehouse_id, warehouse_name, year, period, issue_date, article_id, article_code, article_name, article_symbol;
DEClARE cur_RepInvMonthly CURSOR FOR 
      SELECT  warehouse_id, warehouse_name, year, period, article_id, article_code, article_name, article_symbol, SUM(Case When input = 1 Then Amount Else 0 End) As I, Coalesce(SUM(Case When input = 1 Then Amount * Unit_Cost Else null End), 0) As i_TC, SUM(Case When input = 0 Then Amount Else 0 End) As o_aomunt, Coalesce(SUM(Case When input = 0 Then Amount * Unit_Cost Else null End), 0) As o_TC
	FROM	 TmpRepInv
	GROUP BY warehouse_id, warehouse_name, year, period, article_id, article_code, article_name, article_symbol;
DEClARE cur_RepInvYearly CURSOR FOR 
      SELECT  warehouse_id, warehouse_name, year, article_id, article_code, article_name, article_symbol, SUM(Case When input = 1 Then Amount Else 0 End) As I, Coalesce(SUM(Case When input = 1 Then Amount * Unit_Cost Else null End), 0) As i_TC, SUM(Case When input = 0 Then Amount Else 0 End) As o_aomunt, Coalesce(SUM(Case When input = 0 Then Amount * Unit_Cost Else null End), 0) As o_TC
	FROM	 TmpRepInv
	GROUP BY warehouse_id, warehouse_name, year, article_id, article_code, article_name, article_symbol;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = TRUE;


Drop Table If Exists TmpRepInv;

Create Table TmpRepInv (input int, warehouse_id int, warehouse_name varchar(256), year int, period int, issue_date date,  article_id int, article_code varchar(12), article_name varchar(256), article_symbol varchar(256), amount decimal(18,4), unit_cost decimal(18,4));

Drop Table If Exists TmpRepInvGroup;

Create Table TmpRepInvGroup (warehouse_id int, warehouse_name varchar(256), year int, period int, issue_date date,  article_id int, article_code varchar(12), article_name varchar(256), article_symbol varchar(256), i_amount decimal(18,4), i_unit_cost decimal(18,4), i_total_cost decimal(18,4), o_amount decimal(18,4), o_unit_cost decimal(18,4), o_total_cost decimal(18,4));

/* Create Filters Out Controller */
IF  p_update_filter = 1 THEN
	CALL REP_INV_KARDEX_FILTER(p_company, p_user_id, p_cost_centers, p_warehouses, p_suppliers, p_responsibles, p_years, p_periods, p_formats, p_articles, p_moneys);
END IF;

/* Report Inventory Temporal */
INSERT INTO  TmpRepInv ( input, warehouse_id, warehouse_name, year, period, issue_date, article_id, article_code, article_name, article_symbol, amount, unit_cost )
SELECT
`stock_inputs`.`input`,
`stock_inputs`.`warehouse_id`,
`warehouses`.`name` AS warehouse_name,
`stock_inputs`.`year`,
`stock_inputs`.`period`,
`stock_inputs`.`issue_date`,
`delivery_order_details`.`article_id` AS article_id,
`articles`.`code` AS article_code,
`articles`.`name` AS article_name,
unit_of_measurements.symbol AS article_symbol,
stock_input_details.amount,
stock_input_details.unit_cost
FROM `stock_input_details` 
INNER JOIN `stock_inputs` ON `stock_inputs`.`id` = `stock_input_details`.`stock_input_id` AND `stock_inputs`.`status` = 'A'
INNER JOIN `warehouses` ON `warehouses`.`id` = `stock_inputs`.`warehouse_id` AND `warehouses`.`status` = 'A'
INNER JOIN `rep_inv_cost_centers` ON `rep_inv_cost_centers`.`id` = `warehouses`.`cost_center_id`
INNER JOIN `rep_inv_warehouses` ON `rep_inv_warehouses`.`id` = `stock_inputs`.`warehouse_id`
INNER JOIN `rep_inv_suppliers` ON `rep_inv_suppliers`.`id` = `stock_inputs`.`supplier_id`
INNER JOIN `rep_inv_years` ON `rep_inv_years`.`id` = `stock_inputs`.`year`
INNER JOIN `rep_inv_periods` ON `rep_inv_periods`.`id` = `stock_inputs`.`period` INNER JOIN `rep_inv_formats` ON `rep_inv_formats`.`id` = `stock_inputs`.`format_id`
INNER JOIN `purchase_order_details` ON `purchase_order_details`.`id` = `stock_input_details`.`purchase_order_detail_id`
INNER JOIN `delivery_order_details` ON `delivery_order_details`.`id` = `purchase_order_details`.`delivery_order_detail_id`
INNER JOIN `articles` ON `articles`.`id` = `delivery_order_details`.`article_id`
INNER JOIN `rep_inv_articles` `rep_inv_articles_delivery_order_details` ON `rep_inv_articles_delivery_order_details`.`id` = `delivery_order_details`.`article_id`
INNER JOIN `unit_of_measurements` ON `unit_of_measurements`.`id` = `articles`.`unit_of_measurement_id`
INNER JOIN `purchase_orders` ON `purchase_orders`.`id` = `purchase_order_details`.`purchase_order_id`
INNER JOIN `rep_inv_moneys` ON `rep_inv_moneys`.`id` = `purchase_orders`.`money_id`
WHERE `stock_inputs`.`input` = 1
AND `stock_input_details`.`status` = 'A'
AND `rep_inv_warehouses`.`user` =  p_user_id
AND `rep_inv_suppliers`.`user` =  p_user_id
AND `rep_inv_years`.`user` =  p_user_id
AND `rep_inv_periods`.`user` =  p_user_id
AND `rep_inv_formats`.`user` =  p_user_id
AND `stock_inputs`.`issue_date` >=  p_from_date
AND `stock_inputs`.`issue_date` <=  p_to_date
AND `rep_inv_articles_delivery_order_details`.`user` = p_user_id
ORDER BY 5, 6, 9, 1 DESC;

INSERT INTO  TmpRepInv ( input, warehouse_id, warehouse_name, year, period, issue_date, article_id, article_code, article_name, article_symbol, amount, unit_cost )
SELECT
`stock_inputs`.`input`,
`stock_inputs`.`warehouse_id`,
`warehouses`.`name` AS warehouse_name,
`stock_inputs`.`year`,
`stock_inputs`.`period`,
`stock_inputs`.`issue_date`,
`stock_input_details`.`article_id` AS article_id,
`articles`.`code` AS article_code,
`articles`.`name` AS article_name,
unit_of_measurements.symbol AS article_symbol,
stock_input_details.amount,
stock_input_details.unit_cost
FROM `stock_input_details` 
INNER JOIN `stock_inputs` ON `stock_inputs`.`id` = `stock_input_details`.`stock_input_id` AND `stock_inputs`.`status` = 'A'
INNER JOIN `warehouses` ON `warehouses`.`id` = `stock_inputs`.`warehouse_id` AND `warehouses`.`status` = 'A'
INNER JOIN `rep_inv_cost_centers` ON `rep_inv_cost_centers`.`id` = `warehouses`.`cost_center_id`
INNER JOIN `rep_inv_warehouses` ON `rep_inv_warehouses`.`id` = `stock_inputs`.`warehouse_id`
INNER JOIN `rep_inv_responsibles` ON `rep_inv_responsibles`.`id` = `stock_inputs`.`responsible_id`
INNER JOIN `rep_inv_years` ON `rep_inv_years`.`id` = `stock_inputs`.`year`
INNER JOIN `rep_inv_periods` ON `rep_inv_periods`.`id` = `stock_inputs`.`period` INNER JOIN `rep_inv_formats` ON `rep_inv_formats`.`id` = `stock_inputs`.`format_id`
INNER JOIN `articles` ON `articles`.`id` = `stock_input_details`.`article_id`
INNER JOIN `unit_of_measurements` ON `unit_of_measurements`.`id` = `articles`.`unit_of_measurement_id`
INNER JOIN `rep_inv_articles` ON `rep_inv_articles`.`id` = `articles`.`id`
WHERE `stock_inputs`.`input` = 0
AND `stock_input_details`.`status` = 'A'
AND `rep_inv_warehouses`.`user` =  p_user_id
AND `rep_inv_responsibles`.`user` =  p_user_id
AND `rep_inv_years`.`user` =  p_user_id
AND `rep_inv_periods`.`user` =  p_user_id
AND `rep_inv_formats`.`user` =  p_user_id
AND `stock_inputs`.`issue_date` >=  p_from_date
AND `stock_inputs`.`issue_date` <=  p_to_date
AND `rep_inv_articles`.`user` = p_user_id

ORDER BY 5, 6, 9, 1 DESC;

IF  p_report_type = 5 THEN
CASE  p_kardex_type
    WHEN 4 THEN
      SELECT input, warehouse_id, warehouse_name, year, period, DATE_FORMAT(issue_date, '%d/%m/%Y'), article_id, article_code, article_name, article_symbol, amount, coalesce(unit_cost, 0), coalesce(amount * unit_cost, 0)
	FROM	 TmpRepInv a
	ORDER BY a.warehouse_id, a.article_id, a.year, a.period, a.issue_date, a.input;
    WHEN 3 THEN
      SELECT  input, warehouse_id, warehouse_name, year, period, DATE_FORMAT(issue_date, '%d/%m/%Y'), article_id, article_code, article_name, article_symbol, amount, case when amount = 0 then 0 else total_cost / amount end as total_cost, total_cost
       FROM (
       SELECT input, warehouse_id, warehouse_name, year, period, issue_date, article_id, article_code, article_name, article_symbol, SUM(amount) as amount, coalesce(SUM(amount * unit_cost), 0) as total_cost
	FROM	 TmpRepInv
       GROUP BY input, warehouse_id, warehouse_name, year, period, issue_date, article_id, article_code, article_name, article_symbol
       ) a
       ORDER BY a.warehouse_id, a.article_id, a.year, a.period, a.issue_date, a.input;
    WHEN 2 THEN
          SELECT  input, warehouse_id, warehouse_name, year, period, article_id, article_code, article_name, article_symbol, amount, case when amount = 0 then 0 else total_cost / amount end as total_cost, total_cost
       FROM (
      SELECT  input, warehouse_id, warehouse_name, year, period, article_id, article_code, article_name, article_symbol, SUM(amount) as amount, coalesce(SUM(amount * unit_cost), 0) as total_cost
	FROM	 TmpRepInv
	GROUP BY input, warehouse_id, warehouse_name, year, period, article_id, article_code, article_name, article_symbol
       ) a
	ORDER BY a.warehouse_id, a.article_id, a.year, a.period, a.input;
    WHEN 1 THEN
          SELECT  input, warehouse_id, warehouse_name, year, article_id, article_code, article_name, article_symbol, amount, case when amount = 0 then 0 else total_cost / amount end as total_cost, total_cost
       FROM (
      SELECT  input, warehouse_id, warehouse_name, year, article_id, article_code, article_name, article_symbol, SUM(amount) as amount, coalesce(SUM(amount * unit_cost), 0) as total_cost
	FROM	 TmpRepInv
	GROUP BY input, warehouse_id, warehouse_name, year, article_id, article_code, article_name, article_symbol
      ) a
	ORDER BY a.warehouse_id, a.article_id, a.year, a.input;
END CASE;
END IF;

IF  p_report_type = 4 THEN
CASE  p_kardex_type
    WHEN 4 THEN
OPEN cur_RepInvSummary; 
 
get_RepInvSummary: LOOP 

FETCH cur_RepInvSummary INTO v_warehouse_id, v_warehouse_name, v_article_id, v_article_code, v_article_name, v_article_symbol, v_i_amount, v_i_total_cost, v_o_amount, v_o_total_cost; 

IF v_finished THEN 
    LEAVE get_RepInvSummary; 
END IF; 

SET v_i_unit_cost := 0;
SET v_o_unit_cost := 0;
If v_i_amount > 0 Then
  SET v_i_unit_cost := v_i_total_cost / v_i_amount;
End If;
If v_o_amount > 0 Then
  SET v_o_unit_cost := v_o_total_cost / v_o_amount;
End If;

-- build Report With Group
INSERT INTO  TmpRepInvGroup (warehouse_id, warehouse_name, article_id, article_code, article_name, article_symbol, i_amount, i_unit_cost, i_total_cost, o_amount, o_unit_cost, o_total_cost)
VALUES ( v_warehouse_id, v_warehouse_name, v_article_id, v_article_code, v_article_name, v_article_symbol, v_i_amount, v_i_unit_cost, v_i_total_cost, v_o_amount, v_o_unit_cost, v_o_total_cost );

END LOOP get_RepInvSummary; 

CLOSE cur_RepInvSummary;

    WHEN 3 THEN
OPEN cur_RepInvDaily; 
 
get_RepInvDaily: LOOP 

FETCH cur_RepInvDaily INTO v_warehouse_id, v_warehouse_name, v_year, v_period, v_issue_date, v_article_id, v_article_code, v_article_name, v_article_symbol, v_i_amount, v_i_total_cost, v_o_amount, v_o_total_cost; 

IF v_finished THEN 
    LEAVE get_RepInvDaily; 
END IF; 

SET v_i_unit_cost := 0;
SET v_o_unit_cost := 0;
If v_i_amount > 0 Then
  SET v_i_unit_cost := v_i_total_cost / v_i_amount;
End If;
If v_o_amount > 0 Then
  SET v_o_unit_cost := v_o_total_cost / v_o_amount;
End If;

-- build Report With Group
INSERT INTO  TmpRepInvGroup (warehouse_id, warehouse_name, year, period, issue_date, article_id, article_code, article_name, article_symbol, i_amount, i_unit_cost, i_total_cost, o_amount, o_unit_cost, o_total_cost)
VALUES ( v_warehouse_id, v_warehouse_name, v_year, v_period, v_issue_date, v_article_id, v_article_code, v_article_name, v_article_symbol, v_i_amount, v_i_unit_cost, v_i_total_cost, v_o_amount, v_o_unit_cost, v_o_total_cost );

END LOOP get_RepInvDaily; 

CLOSE cur_RepInvDaily;

    WHEN 2 THEN
OPEN cur_RepInvMonthly; 
 
get_RepInvMonthly: LOOP 

FETCH cur_RepInvMonthly INTO v_warehouse_id, v_warehouse_name, v_year, v_period, v_article_id, v_article_code, v_article_name, v_article_symbol, v_i_amount, v_i_total_cost, v_o_amount, v_o_total_cost; 

IF v_finished THEN 
    LEAVE get_RepInvMonthly; 
END IF; 

SET v_i_unit_cost := 0;
SET v_o_unit_cost := 0;
If v_i_amount > 0 Then
  SET v_i_unit_cost := v_i_total_cost / v_i_amount;
End If;
If v_o_amount > 0 Then
  SET v_o_unit_cost := v_o_total_cost / v_o_amount;
End If;

-- build Report With Group
INSERT INTO  TmpRepInvGroup (warehouse_id, warehouse_name, year, period, article_id, article_code, article_name, article_symbol, i_amount, i_unit_cost, i_total_cost, o_amount, o_unit_cost, o_total_cost)
VALUES ( v_warehouse_id, v_warehouse_name, v_year, v_period, v_article_id, v_article_code, v_article_name, v_article_symbol, v_i_amount, v_i_unit_cost, v_i_total_cost, v_o_amount, v_o_unit_cost, v_o_total_cost );

END LOOP get_RepInvMonthly; 

CLOSE cur_RepInvMonthly;

    WHEN 1 THEN
OPEN cur_RepInvYearly; 
 
get_RepInvYearly: LOOP 

FETCH cur_RepInvYearly INTO v_warehouse_id, v_warehouse_name, v_year, v_article_id, v_article_code, v_article_name, v_article_symbol, v_i_amount, v_i_total_cost, v_o_amount, v_o_total_cost; 

IF v_finished THEN 
    LEAVE get_RepInvYearly; 
END IF; 

SET v_i_unit_cost := 0;
SET v_o_unit_cost := 0;
If v_i_amount > 0 Then
  SET v_i_unit_cost := v_i_total_cost / v_i_amount;
End If;
If v_o_amount > 0 Then
  SET v_o_unit_cost := v_o_total_cost / v_o_amount;
End If;

-- build Report With Group
INSERT INTO  TmpRepInvGroup (warehouse_id, warehouse_name, year, article_id, article_code, article_name, article_symbol, i_amount, i_unit_cost, i_total_cost, o_amount, o_unit_cost, o_total_cost)
VALUES ( v_warehouse_id, v_warehouse_name, v_year, v_article_id, v_article_code, v_article_name, v_article_symbol, v_i_amount, v_i_unit_cost, v_i_total_cost, v_o_amount, v_o_unit_cost, v_o_total_cost );

END LOOP get_RepInvYearly; 

CLOSE cur_RepInvYearly;
END CASE;

SELECT warehouse_id, warehouse_name, year, period, DATE_FORMAT(issue_date, '%d/%m/%Y'), article_id, article_code, article_name, article_symbol, i_amount, i_unit_cost, i_total_cost, o_amount, o_unit_cost, o_total_cost
FROM	 TmpRepInvGroup;

END IF;


END //
DELIMITER ;