DELIMITER $$
--
-- Procedures
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

DELIMITER ;