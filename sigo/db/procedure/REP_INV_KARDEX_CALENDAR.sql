DELIMITER $$

DROP PROCEDURE IF EXISTS `REP_INV_KARDEX_CALENDAR`$$

/*
p_update_filter : 0 No se actualiza tablas filtros, 1 Si se actualizan filtros
p_report_type   : 4 Kárdex E/S, 5 Kárdex Movimiento
*/
CREATE PROCEDURE REP_INV_KARDEX_CALENDAR (
  IN p_update_filter INT,
  IN p_company_id INT,
  IN p_cost_center INT,
  IN p_report_type INT,
  IN p_kardex_type INT,
  IN p_user_id INT,
  IN p_from_date DATE,
  IN p_to_date DATE,
  IN p_warehouses VARCHAR(500),
  IN p_suppliers VARCHAR(500),
  IN p_responsibles VARCHAR(500),
  IN p_years VARCHAR(500),
  IN p_periods VARCHAR(500),
  IN p_formats VARCHAR(500),
  IN p_articles VARCHAR(500),
  IN p_moneys VARCHAR(500)
)
BEGIN

-- Declarar Variables
declare v_finished INTEGER DEFAULT FALSE;
declare v_input, v_warehouse_id, v_period, v_article_id, v_year INTEGER;
declare v_warehouse_name, v_article_code, v_article_name, v_article_symbol VARCHAR(256);
declare v_issue_date DATE;
declare v_i_amount, v_i_unit_cost, v_i_total_cost, v_o_amount, v_o_unit_cost, v_o_total_cost DECIMAL(18,4);

-- Declarar Cursors
declare cur_RepInvSummary CURSOR FOR 
  SELECT warehouse_id, warehouse_name, article_id, article_code, article_name, article_symbol, 
         SUM(Case When input = 1 Then Amount Else 0 End) As I,
         Coalesce(SUM(Case When input = 1 Then Amount * Unit_Cost Else null End), 0) As i_TC,
         Coalesce(SUM(Case When input = 0 Then Amount Else 0 End), 0) As o_aomunt,
         Coalesce(SUM(Case When input = 0 Then Amount * Unit_Cost Else null End), 0) As o_TC
  FROM   TmpRepInv
  GROUP BY warehouse_id, warehouse_name, article_id, article_code, article_name, article_symbol;
declare cur_RepInvDaily CURSOR FOR 
  SELECT warehouse_id, warehouse_name, year, period, issue_date, article_id, article_code, article_name, article_symbol,
         SUM(Case When input = 1 Then Amount Else 0 End) As I,
         Coalesce(SUM(Case When input = 1 Then Amount * Unit_Cost Else null End), 0) As i_TC,
         SUM(Case When input = 0 Then Amount Else 0 End) As o_aomunt,
         Coalesce(SUM(Case When input = 0 Then Amount * Unit_Cost Else null End), 0) As o_TC
  FROM   TmpRepInv
  GROUP BY warehouse_id, warehouse_name, year, period, issue_date, article_id, article_code, article_name, article_symbol;
declare cur_RepInvMonthly CURSOR FOR 
  SELECT  warehouse_id, warehouse_name, year, period, article_id, article_code, article_name, article_symbol,
          SUM(Case When input = 1 Then Amount Else 0 End) As I,
          Coalesce(SUM(Case When input = 1 Then Amount * Unit_Cost Else null End), 0) As i_TC,
          SUM(Case When input = 0 Then Amount Else 0 End) As o_aomunt,
          Coalesce(SUM(Case When input = 0 Then Amount * Unit_Cost Else null End), 0) As o_TC
  FROM   TmpRepInv
  GROUP BY warehouse_id, warehouse_name, year, period, article_id, article_code, article_name, article_symbol;
declare cur_RepInvYearly CURSOR FOR 
  SELECT  warehouse_id, warehouse_name, year, article_id, article_code, article_name, article_symbol,
          SUM(Case When input = 1 Then Amount Else 0 End) As I,
          Coalesce(SUM(Case When input = 1 Then Amount * Unit_Cost Else null End), 0) As i_TC,
          SUM(Case When input = 0 Then Amount Else 0 End) As o_aomunt,
          Coalesce(SUM(Case When input = 0 Then Amount * Unit_Cost Else null End), 0) As o_TC
  FROM   TmpRepInv
  GROUP BY warehouse_id, warehouse_name, year, article_id, article_code, article_name, article_symbol;

declare CONTINUE HANDLER FOR NOT FOUND SET v_finished = TRUE;

-- Declarar Tablas Temporales
Drop Table If Exists TmpRepInv;

Create Table TmpRepInv (input int, warehouse_id int, warehouse_name varchar(256), year int, period int, issue_date date,  article_id int, article_code varchar(12), article_name varchar(256), article_symbol varchar(256), amount decimal(18,4), unit_cost decimal(18,4));

Drop Table If Exists TmpRepInvGroup;

Create Table TmpRepInvGroup (warehouse_id int, warehouse_name varchar(256), year int, period int, issue_date date,  article_id int, article_code varchar(12), article_name varchar(256), article_symbol varchar(256), i_amount decimal(18,4), i_unit_cost decimal(18,4), i_total_cost decimal(18,4), o_amount decimal(18,4), o_unit_cost decimal(18,4), o_total_cost decimal(18,4));

/* Create Filters Out Controller */
IF  p_update_filter = 1 THEN
  CALL REP_INV_KARDEX_FILTER(p_company_id, p_user_id, p_cost_center, p_warehouses, p_suppliers, p_responsibles, p_years, p_periods, p_formats, p_articles, p_moneys);
END IF;

/* Report Inventory Temporal */
# Stock Inputs
INSERT INTO  TmpRepInv ( input, warehouse_id, warehouse_name, year, period, issue_date, article_id, article_code, article_name, article_symbol, amount, unit_cost )
SELECT
si.`input`,
si.`warehouse_id`,
riw.`name` AS warehouse_name,
si.`year`,
si.`period`,
si.`issue_date`,
dod.`article_id` AS article_id,
a.`code` AS article_code,
a.`name` AS article_name,
um.`symbol` AS article_symbol,
sid.`amount`,
sid.`unit_cost`
FROM `stock_input_details` sid
INNER JOIN `stock_inputs` si ON sid.`stock_input_id` = si.`id` AND si.`status` = 'A'
#INNER JOIN `warehouses` w ON w.`id` = si.`warehouse_id`
INNER JOIN `rep_inv_warehouses` riw ON si.`warehouse_id` = riw.`id`
INNER JOIN `rep_inv_suppliers` ris ON si.`supplier_id` = ris.`id`
INNER JOIN `rep_inv_years` riy ON si.`year` = riy.`id`
INNER JOIN `rep_inv_periods` rip ON si.`period` = rip.`id`
INNER JOIN `rep_inv_formats` rif ON si.`format_id` = rif.`id`
INNER JOIN `purchase_order_details` pod ON sid.`purchase_order_detail_id` = pod.`id`
INNER JOIN `delivery_order_details` dod ON pod.`delivery_order_detail_id` = dod.`id`
INNER JOIN `rep_inv_articles` ria ON dod.`article_id` = ria.`id`
INNER JOIN `articles` a ON a.`id` = dod.`article_id`
INNER JOIN `unit_of_measurements` um ON um.`id` = a.`unit_of_measurement_id`
#INNER JOIN `purchase_orders` po ON po.`id` = pod.`purchase_order_id`
#INNER JOIN `rep_inv_moneys` rim ON rim.`id` = po.`money_id`
WHERE si.`input` = 1
AND si.`company_id` = p_company_id
AND si.`cost_center_id` = p_cost_center
AND sid.`status` = 'A'
#AND ric.`user` =  p_user_id
AND riw.`user` =  p_user_id
AND ris.`user` =  p_user_id
AND riy.`user` =  p_user_id
AND rip.`user` =  p_user_id
AND rif.`user` =  p_user_id
AND ria.`user` = p_user_id
#AND rim.`user` = p_user_id
AND si.`issue_date` >=  p_from_date
AND si.`issue_date` <=  p_to_date
ORDER BY 5, 6, 9, 1 DESC;

# Stock Outputs
INSERT INTO  TmpRepInv ( input, warehouse_id, warehouse_name, year, period, issue_date, article_id, article_code, article_name, article_symbol, amount, unit_cost )
SELECT
si.`input`,
si.`warehouse_id`,
riw.`name` AS warehouse_name,
si.`year`,
si.`period`,
si.`issue_date`,
sid.`article_id` AS article_id,
a.`code` AS article_code,
a.`name` AS article_name,
um.`symbol` AS article_symbol,
sid.`amount`,
sid.`unit_cost`
FROM `stock_input_details` sid
INNER JOIN `stock_inputs` si ON si.`id` = sid.`stock_input_id` AND si.`status` = 'A'
#INNER JOIN `warehouses` w ON w.`id` = si.`warehouse_id`
INNER JOIN `rep_inv_warehouses` riw ON si.`warehouse_id` = riw.`id`
INNER JOIN `rep_inv_responsibles` rir ON si.`responsible_id` = rir.`id`
INNER JOIN `rep_inv_years` riy ON si.`year` = riy.`id`
INNER JOIN `rep_inv_periods` rip ON si.`period` = rip.`id`
INNER JOIN `rep_inv_formats` rif ON si.`format_id` = rif.`id`
INNER JOIN `rep_inv_articles` ria ON ria.`id` = sid.`article_id`
INNER JOIN `articles` a ON a.`id` = sid.`article_id`
INNER JOIN `unit_of_measurements` um ON um.`id` = a.`unit_of_measurement_id`
WHERE si.`input` = 0
AND si.`company_id` = p_company_id
AND si.`cost_center_id` = p_cost_center
AND sid.`status` = 'A'
#AND ric.`user` =  p_user_id
AND riw.`user` =  p_user_id
AND rir.`user` =  p_user_id
AND riy.`user` =  p_user_id
AND rip.`user` =  p_user_id
AND rif.`user` =  p_user_id
AND ria.`user` = p_user_id
AND si.`issue_date` >=  p_from_date
AND si.`issue_date` <=  p_to_date

ORDER BY 5, 6, 9, 1 DESC;

IF  p_report_type = 5 THEN
  -- 5 Kárdex Movimiento
  CASE  p_kardex_type
    WHEN 4 THEN
      SELECT input, warehouse_id, warehouse_name, year, period, DATE_FORMAT(issue_date, '%d/%m/%Y'), article_id, article_code, article_name, article_symbol, amount, coalesce(unit_cost, 0), coalesce(amount * unit_cost, 0)
      FROM   TmpRepInv a
      ORDER BY a.warehouse_id, a.article_id, a.year, a.period, a.issue_date, a.input;
    WHEN 3 THEN
      SELECT  input, warehouse_id, warehouse_name, year, period, DATE_FORMAT(issue_date, '%d/%m/%Y'), article_id, article_code, article_name, article_symbol, amount, case when amount = 0 then 0 else total_cost / amount end as total_cost, total_cost
      FROM (
        SELECT input, warehouse_id, warehouse_name, year, period, issue_date, article_id, article_code, article_name, article_symbol, SUM(amount) as amount, coalesce(SUM(amount * unit_cost), 0) as total_cost
        FROM   TmpRepInv
        GROUP BY input, warehouse_id, warehouse_name, year, period, issue_date, article_id, article_code, article_name, article_symbol
      ) a
      ORDER BY a.warehouse_id, a.article_id, a.year, a.period, a.issue_date, a.input;
    WHEN 2 THEN
      SELECT  input, warehouse_id, warehouse_name, year, period, article_id, article_code, article_name, article_symbol, amount, case when amount = 0 then 0 else total_cost / amount end as total_cost, total_cost
      FROM (
        SELECT  input, warehouse_id, warehouse_name, year, period, article_id, article_code, article_name, article_symbol, SUM(amount) as amount, coalesce(SUM(amount * unit_cost), 0) as total_cost
        FROM   TmpRepInv
        GROUP BY input, warehouse_id, warehouse_name, year, period, article_id, article_code, article_name, article_symbol
      ) a
      ORDER BY a.warehouse_id, a.article_id, a.year, a.period, a.input;
    WHEN 1 THEN
      SELECT  input, warehouse_id, warehouse_name, year, article_id, article_code, article_name, article_symbol, amount, case when amount = 0 then 0 else total_cost / amount end as total_cost, total_cost
      FROM (
        SELECT  input, warehouse_id, warehouse_name, year, article_id, article_code, article_name, article_symbol, SUM(amount) as amount, coalesce(SUM(amount * unit_cost), 0) as total_cost
        FROM   TmpRepInv
        GROUP BY input, warehouse_id, warehouse_name, year, article_id, article_code, article_name, article_symbol
      ) a
      ORDER BY a.warehouse_id, a.article_id, a.year, a.input;
  END CASE;
END IF;

IF  p_report_type = 4 THEN
  -- 4 Kárdex E/S
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

      -- Build Report With Group (4)
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

      -- Build Report With Group (3)
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

      -- Build Report With Group (2)
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

      -- Build Report With Group (1)
      INSERT INTO  TmpRepInvGroup (warehouse_id, warehouse_name, year, article_id, article_code, article_name, article_symbol, i_amount, i_unit_cost, i_total_cost, o_amount, o_unit_cost, o_total_cost)
      VALUES ( v_warehouse_id, v_warehouse_name, v_year, v_article_id, v_article_code, v_article_name, v_article_symbol, v_i_amount, v_i_unit_cost, v_i_total_cost, v_o_amount, v_o_unit_cost, v_o_total_cost );

      END LOOP get_RepInvYearly; 

      CLOSE cur_RepInvYearly;
  END CASE;

  -- Recuperar Salida del Reporte para todas las opciones
  SELECT warehouse_id, warehouse_name, year, period, DATE_FORMAT(issue_date, '%d/%m/%Y'), article_id, article_code, article_name, article_symbol, i_amount, i_unit_cost, i_total_cost, o_amount, o_unit_cost, o_total_cost
  FROM   TmpRepInvGroup;

END IF;


END $$
DELIMITER ;
