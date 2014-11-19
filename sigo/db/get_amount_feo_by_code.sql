DELIMITER $$
DROP FUNCTION IF EXISTS `get_amount_feo_by_code` $$

CREATE FUNCTION `get_amount_feo_by_code` (category varchar(6), budget int) returns float
BEGIN
	DECLARE amount float;
	SELECT t_amount INTO amount FROM
	(SELECT CONCAT('0', inputcategories.category_id) as category_id, 
		inputcategories.description, 
		SUM(ROUND(ROUND(items.price * items.quantity, 2) * items.measured, 4)) as t_amount
		FROM inputcategories,
		(
		  SELECT  inputs.cod_input, inputs.quantity, inputs.price, itembybudgets.measured, 
			inputs.item_id, inputs.`order`
			FROM itembybudgets,
			(
			  SELECT quantity, price, `order`, item_id, cod_input, budget_id
				FROM inputbybudgetanditems
			) AS inputs
			WHERE inputs.item_id = itembybudgets.item_id AND
				inputs.`order` = itembybudgets.`order` AND
				inputs.budget_id = itembybudgets.budget_id AND
				itembybudgets.budget_id = budget
		) AS items
		WHERE items.cod_input LIKE CONCAT('0', CONCAT(category_id, '%'))
		GROUP BY category_id
	ORDER BY category_id) as feo
	WHERE feo.category_id like category;

	RETURN amount;
END $$
DELIMITER ;