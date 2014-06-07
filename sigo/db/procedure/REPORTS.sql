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

DROP FUNCTION IF EXISTS `get_valorization_actual`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `get_amount_actual`( type_article CHAR(2), v_order TEXT, v_budget_id INTEGER, v_valorization_id INTEGER) RETURNS float
BEGIN

  DECLARE done INT DEFAULT FALSE;

  DECLARE v_id FLOAT;
  DECLARE v_price FLOAT;
  DECLARE v_created_at DATETIME;
  DECLARE v_total FLOAT;

  DECLARE i_measured FLOAT;
 
  DECLARE sub_elements CURSOR FOR 
    SELECT id, price FROM itembybudgets WHERE `order` LIKE CONVERT(CONCAT(v_order, "%") using utf8) collate utf8_spanish_ci AND budget_id = v_budget_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  
  SET v_total=0;

  OPEN sub_elements;
  read_loop: LOOP
    FETCH sub_elements INTO v_id, v_price;
    
    SET @i_measured = (SELECT actual_measured FROM valorizationitems WHERE valorization_id = v_valorization_id AND itembybudget_id = v_id LIMIT 1);
    SET i_measured  = (SELECT @i_measured);
 
    IF done THEN
      LEAVE read_loop;
    END IF;
    SET v_total = v_total + (IFNULL(v_price, 0) * IFNULL(i_measured, 0));
  END LOOP;
  CLOSE sub_elements;
  
  RETURN v_total;
END$$

DROP FUNCTION IF EXISTS `get_valorization_acumulated`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `get_amount_acumulated`(type_article CHAR(2), v_order TEXT, v_budget_id INTEGER, v_current_date DATETIME, v_valorization_id INTEGER) RETURNS float
BEGIN

  DECLARE done INT DEFAULT FALSE;

  DECLARE v_id FLOAT;
  DECLARE v_price FLOAT;
  DECLARE v_created_at DATETIME;
  DECLARE v_total FLOAT;

  DECLARE i_measured FLOAT;
  DECLARE i_prev_measured FLOAT;

  DECLARE sub_elements CURSOR FOR 
    SELECT id, price, created_at FROM itembybudgets WHERE `order` LIKE CONVERT(CONCAT(v_order, "%") using utf8) collate utf8_spanish_ci AND budget_id = v_budget_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
  
  SET v_total=0;

  OPEN sub_elements;
  read_loop: LOOP
    FETCH sub_elements INTO v_id, v_price, v_created_at;
    
    SET @i_measured = (SELECT actual_measured FROM valorizationitems WHERE valorization_id = v_valorization_id AND itembybudget_id = v_id LIMIT 1);
    SET i_measured  = (SELECT @i_measured);
    SET i_prev_measured = (SELECT get_prev_valorizations(v_created_at, v_id));
  
    IF done THEN
      LEAVE read_loop;
    END IF;
    SET v_total = v_total + (IFNULL(v_price, 0) * IFNULL(i_measured, 0)) + (IFNULL(i_prev_measured, 0) * IFNULL(v_price, 0));
  END LOOP;
  CLOSE sub_elements;
  
  RETURN v_total;
END$$

DELIMITER ;