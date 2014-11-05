-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE DEFINER=`root`@`localhost` FUNCTION `get_amount_acumulated`(v_order TEXT, v_budget_id INTEGER, v_current_date DATETIME, v_valorization_id INTEGER) RETURNS float
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
		SET i_prev_measured = (SELECT get_prev_valorizations(v_current_date, v_id));
	
		IF done THEN
			LEAVE read_loop;
		END IF;
		SET v_total = v_total + (IFNULL(v_price, 0) * IFNULL(i_measured, 0)) + (IFNULL(i_prev_measured, 0) * IFNULL(v_price, 0));
	END LOOP;
	CLOSE sub_elements;
	
	RETURN v_total;
END