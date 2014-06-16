DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `get_input_ids_for_wbs`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_input_ids_for_wbs`(IN input_prefix CHAR(120), IN budget_id INT)
BEGIN
	
	DECLARE done INT DEFAULT 0;
	DECLARE v_id INT;
	DECLARE v_order CHAR(120);
    
    DECLARE itembybudgets_cursor CURSOR FOR SELECT item_id, `order` from itembybudgets WHERE budget_id = budget_id;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;

	OPEN itembybudgets_cursor;

	DROP TEMPORARY TABLE IF EXISTS itembybudgets_temp;     -- make sure it doesnt already exist
	CREATE TEMPORARY TABLE itembybudgets_temp (
	  id int,
	  order_str varchar(120) -- do we want to enforce array as a set?
	) ENGINE=memory;


	REPEAT
    FETCH itembybudgets_cursor INTO v_id, v_order;
      
       INSERT INTO itembybudgets_temp(id, order_str) VALUES(v_id, v_order);
	UNTIL done END REPEAT;

	CLOSE itembybudgets_cursor;
	
	SELECT itembybudgets_temp.id,  itembybudgets_temp.order_str, inputbybudgetanditems.input, SUM(inputbybudgetanditems.quantity), price,price*SUM(inputbybudgetanditems.quantity) ,unit, cod_input FROM inputbybudgetanditems, itembybudgets_temp WHERE itembybudgets_temp.id = inputbybudgetanditems.item_id AND inputbybudgetanditems.budget_id = budget_id AND inputbybudgetanditems.cod_input LIKE input_prefix AND itembybudgets_temp.order_str = `order`  COLLATE utf8_unicode_ci GROUP BY itembybudgets_temp.id,  itembybudgets_temp.order_str, cod_input; 
																

    DROP TEMPORARY TABLE itembybudgets_temp;

END$$

--
-- Functions
--
DROP FUNCTION IF EXISTS `get_amount_actual`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `get_amount_actual`(v_order TEXT, v_budget_id INTEGER, v_valorization_id INTEGER) RETURNS float
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

DROP FUNCTION IF EXISTS `get_amount_acumulated`$$
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
		SET i_prev_measured = (SELECT get_prev_valorizations(v_created_at, v_id));
	
		IF done THEN
			LEAVE read_loop;
		END IF;
		SET v_total = v_total + (IFNULL(v_price, 0) * IFNULL(i_measured, 0)) + (IFNULL(i_prev_measured, 0) * IFNULL(v_price, 0));
	END LOOP;
	CLOSE sub_elements;
	
	RETURN v_total;
END$$

DROP FUNCTION IF EXISTS `get_amount_prev`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `get_amount_prev`(v_order TEXT, v_budget_id INTEGER, v_current_date DATETIME) RETURNS float
BEGIN

	DECLARE done INT DEFAULT FALSE;

	DECLARE v_id FLOAT;
	DECLARE v_price FLOAT;
	DECLARE v_created_at DATETIME;
	DECLARE v_total FLOAT;

	DECLARE i_measured FLOAT;
	DECLARE i_prev_measured FLOAT;

	DECLARE sub_elements CURSOR FOR 
		SELECT id, price, created_at FROM itembybudgets 
			WHERE itembybudgets.`order` LIKE CONVERT(CONCAT(v_order, "%")   using utf8) collate utf8_spanish_ci
			AND budget_id = v_budget_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
	SET v_total=0;

	OPEN sub_elements;
	read_loop: LOOP
		FETCH sub_elements INTO v_id, v_price, v_created_at;
		
	
		SET i_prev_measured = (SELECT get_prev_valorizations(v_created_at, v_id));
	
		IF done THEN
			LEAVE read_loop;
		END IF;
		SET v_total = v_total + (IFNULL(i_prev_measured, 0) * IFNULL(v_price, 0));
	END LOOP;
	CLOSE sub_elements;
	
	RETURN v_total;
END$$

DROP FUNCTION IF EXISTS `get_partial_cost`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `get_partial_cost`(v_order TEXT) RETURNS float
BEGIN
	SET @v_total='';
	SELECT SUM(price * quantity) into @v_total
	FROM inputbybudgetanditems 
	WHERE `order`
	LIKE CONVERT(CONCAT(v_order, '%') USING latin1);
	RETURN @v_total;
END$$

DROP FUNCTION IF EXISTS `get_prev_valorizations`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `get_prev_valorizations`(v_current_date DATETIME, v_itembybudget_id INTEGER) RETURNS float
BEGIN
	
	DECLARE sum FLOAT;

	SET sum = (SELECT sum(ROUND(actual_measured)) FROM valorizationitems WHERE (valorization_id IN (SELECT id FROM valorizations WHERE valorization_date < v_current_date) AND itembybudget_id = v_itembybudget_id));


RETURN sum;
END$$

DROP FUNCTION IF EXISTS `get_total_cost`$$
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
    
		SET v_total = v_total + (v_measured * IFNULL(get_partial_cost(t_order), 0));
	END LOOP;
	CLOSE sub_elements;
RETURN v_total;
END$$

DELIMITER ;