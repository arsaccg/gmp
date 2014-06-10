DELIMITER $$
--
-- Functions
--

DROP FUNCTION IF EXISTS `scheduled_sale`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `scheduled_sale`( type_article CHAR(2), cost_center_id INT ) RETURNS float
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_total FLOAT; 
  DECLARE v_sum FLOAT;
  DECLARE quantity_cursor CURSOR FOR 
    SELECT DISTINCT ibi.quantity*ibi.price as `total`
	  FROM `inputbybudgetanditems` ibi, `articles` a, `budgets` b 
	  WHERE b.cost_center_id = cost_center_id 
    AND b.type_of_budget = 1 
    AND ibi.budget_id = b.id 
    AND ibi.article_id = a.id 
    AND ibi.cod_input 
    LIKE CONVERT(CONCAT(type_article, "%") using utf8) collate utf8_spanish_ci;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  SET v_sum = 0;

  OPEN quantity_cursor;

    read_loop: LOOP
	  FETCH quantity_cursor INTO v_total;

	  IF done THEN
	    LEAVE read_loop;
	  END IF;

	  SET v_sum = v_sum + IFNULL(v_total, 0);
    END LOOP;

  CLOSE quantity_cursor;

  RETURN ROUND(v_sum, 2);
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
    WHERE items.cod_input LIKE CONCAT('0', CONCAT(type_article, '%'))
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