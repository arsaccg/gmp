-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE DEFINER=`root`@`localhost` FUNCTION `get_total_cost`(v_order TEXT, v_budget_id INTEGER) RETURNS double
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_measured FLOAT(10,2);
	DECLARE v_price FLOAT(10,2);
	DECLARE v_total DOUBLE;
    DECLARE t_order TEXT;
	DECLARE sub_elements CURSOR FOR 
		SELECT measured, `order` AS 't_order'  FROM itembybudgets WHERE `order` LIKE CONVERT(CONCAT(v_order, "%") USING latin1) AND budget_id = v_budget_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	SET v_total=0;

	OPEN sub_elements;
	read_loop: LOOP
		FETCH sub_elements INTO v_measured, t_order;

	    IF done THEN
			LEAVE read_loop;
		END IF;

		IF v_measured IS NULL THEN
	      SET v_measured = 0;
	    END IF;
    
		SET v_total = ROUND(v_total + ROUND((v_measured * IFNULL(get_partial_cost(t_order, v_budget_id), 0)),4),4);
	END LOOP;
	CLOSE sub_elements;
RETURN v_total;
END