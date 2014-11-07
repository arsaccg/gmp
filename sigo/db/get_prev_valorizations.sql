-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE DEFINER=`root`@`localhost` FUNCTION `get_prev_valorizations`(v_current_date DATETIME, v_itembybudget_id INTEGER) RETURNS float
BEGIN
	
	DECLARE sum FLOAT;

	SET sum = (SELECT sum(ROUND(actual_measured,4)) 
		FROM valorizationitems 
		WHERE (valorization_id IN 
			(SELECT id FROM valorizations 
			WHERE valorization_date < v_current_date) 
			AND itembybudget_id = v_itembybudget_id));

RETURN sum;
END