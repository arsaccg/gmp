DROP FUNCTION IF EXISTS amountcontract;
DELIMITER $$
CREATE FUNCTION amountcontract(orderitem VARCHAR(20), budgetid INT)
  RETURNS INT
BEGIN
  DECLARE amount INT;
  DECLARE id INTEGER;
  DECLARE ic INTEGER;
  DECLARE o VARCHAR(20);
  DECLARE me FLOAT;
  DECLARE pr INTEGER;
  DECLARE cur_item CURSOR FOR SELECT `id`, `item_code`, `order`, `measured`, `price` FROM itembybudgets WHERE budget_id = budgetid AND `order` like concat(orderitem, '%') AND measured > 0;

  SET amount = 0;

  OPEN cur_item;
  
  FETCH cur_item INTO id, ic, o, me, pr;

  CLOSE cur_item;

  RETURN amount;
END;
$$
DELIMITER ;