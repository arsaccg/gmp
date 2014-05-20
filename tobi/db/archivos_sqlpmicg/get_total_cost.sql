DELIMITER $$

CREATE DEFINER=`root`@`localhost` FUNCTION `get_total_cost`(v_order TEXT) RETURNS float
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_measured FLOAT;
	DECLARE v_price FLOAT;
	DECLARE v_total FLOAT;
	DECLARE sub_elements CURSOR FOR 
		SELECT measured, price FROM itembybudgets WHERE `order` LIKE CONCAT(v_order, "%");
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	SET v_total=0;

	OPEN sub_elements;
	read_loop: LOOP
		FETCH sub_elements INTO v_measured, v_price;
		
		IF done THEN
			LEAVE read_loop;
		END IF;
		SET v_total = v_total + (v_measured * v_price);
	END LOOP;
	CLOSE sub_elements;
RETURN v_total;
END