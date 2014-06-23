DELIMITER $$

--
-- Functions
--

DROP FUNCTION IF EXISTS `get_scheduled_sale`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `get_scheduled_sale`( type_article INT, cost_center_id INT ) RETURNS FLOAT
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_budget_id INT; 
  DECLARE v_code_item VARCHAR(100);
  DECLARE v_distribution_value FLOAT;
  DECLARE v_distribution_month VARCHAR(100);
  DECLARE i_scheduled FLOAT;

  DECLARE scheduled_cursor CURSOR FOR 
    SELECT d.budget_id, d.code, di.value, di.month 
    FROM distributions d, budgets b, distribution_items di 
    WHERE d.budget_id = b.id 
    AND di.distribution_id = d.id 
    AND d.cost_center_id = cost_center_id
    AND di.value IS NOT NULL
    AND MONTH( di.month ) = MONTH(NOW());
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  SET i_scheduled = 0;

  DROP TEMPORARY TABLE IF EXISTS debugger_temp;
  CREATE TEMPORARY TABLE debugger_temp (
  id INT NOT NULL AUTO_INCREMENT,
  budget_id int,
  order_str varchar(120),
  result float,
  PRIMARY KEY(id)
  ) ENGINE=memory;

  OPEN scheduled_cursor;

    read_loop: LOOP
      FETCH scheduled_cursor INTO v_budget_id, v_code_item, v_distribution_value, v_distribution_month;

      IF done THEN LEAVE read_loop; END IF;

      SET @i_scheduled = (
        SELECT SUM((ibi.quantity * ibi.price))
        FROM inputbybudgetanditems ibi, budgets b 
        WHERE b.type_of_budget = 1 
        AND b.id = ibi.budget_id 
        AND ibi.budget_id = v_budget_id 
        AND ibi.order = v_code_item
        AND ibi.cod_input LIKE CONCAT('0', type_article, '%')
      );

    INSERT INTO debugger_temp(`budget_id`, `order_str`, `result`) VALUES(v_budget_id, v_code_item, @i_scheduled);

      IF @i_scheduled IS NULL THEN
        SET @i_scheduled = 0;
      END IF;

      SET i_scheduled  = i_scheduled + (@i_scheduled*v_distribution_value);

    END LOOP;

  CLOSE scheduled_cursor;

  RETURN ROUND(i_scheduled, 2);
END$$


DROP FUNCTION IF EXISTS `get_valorized_sale`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `get_valorized_sale`( type_article INT, cost_center_id INT ) RETURNS FLOAT
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_budget_id INT; 
  DECLARE v_itembybudget_id INT; 
  DECLARE v_actual_measured FLOAT;
  DECLARE i_measured FLOAT;

  DECLARE measured_cursor CURSOR FOR 
    SELECT b.id, vi.itembybudget_id, vi.actual_measured 
    FROM `budgets` b, `itembybudgets` ibb, `valorizationitems` vi 
    WHERE b.type_of_budget = 1 
    AND b.cost_center_id = cost_center_id 
    AND ibb.budget_id = b.id 
    AND vi.itembybudget_id = ibb.id;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  SET i_measured = 0;

  OPEN measured_cursor;

    read_loop: LOOP
    FETCH measured_cursor INTO v_budget_id, v_itembybudget_id, v_actual_measured;

    IF done THEN
      LEAVE read_loop;
    END IF;

      SET @i_measured = (
    SELECT DISTINCT SUM(items.price * items.quantity * items.measured)
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
        itembybudgets.budget_id = v_budget_id AND
        itembybudgets.id = v_itembybudget_id
    ) AS items
    WHERE items.cod_input LIKE CONCAT('0', type_article, '%')
    GROUP BY category_id
    ORDER BY category_id
      );

    IF @i_measured IS NULL THEN
      SET @i_measured = 0;
    END IF;

    SET i_measured  = i_measured + @i_measured;

    END LOOP;

  CLOSE measured_cursor;

  RETURN ROUND(i_measured, 2);
END$$

DROP FUNCTION IF EXISTS `get_cost_goal`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `get_cost_goal`( type_article INT, cost_center_id INT ) RETURNS FLOAT
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_budget_id INT; 
  DECLARE v_itembybudget_id INT; 
  DECLARE v_actual_measured FLOAT;
  DECLARE i_measured FLOAT;

  DECLARE measured_cursor CURSOR FOR 
    SELECT b.id, vi.itembybudget_id, vi.actual_measured 
    FROM `budgets` b, `itembybudgets` ibb, `valorizationitems` vi 
    WHERE b.type_of_budget = 0 
    AND b.cost_center_id = cost_center_id 
    AND ibb.budget_id = b.id 
    AND vi.itembybudget_id = ibb.id;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  SET i_measured = 0;

  OPEN measured_cursor;

    read_loop: LOOP
    FETCH measured_cursor INTO v_budget_id, v_itembybudget_id, v_actual_measured;

    IF done THEN
      LEAVE read_loop;
    END IF;

      SET @i_measured = (
    SELECT DISTINCT SUM(items.price * items.quantity * items.measured)
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
        itembybudgets.budget_id = v_budget_id AND
        itembybudgets.id = v_itembybudget_id
    ) AS items
    WHERE items.cod_input LIKE CONCAT('0', type_article, '%')
    GROUP BY category_id
    ORDER BY category_id
      );

    IF @i_measured IS NULL THEN
      SET @i_measured = 0;
    END IF;

    SET i_measured  = i_measured + @i_measured;

    END LOOP;

  CLOSE measured_cursor;

  RETURN ROUND(i_measured, 2);
END$$

DELIMITER ;