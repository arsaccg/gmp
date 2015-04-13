DELIMITER $$

DROP PROCEDURE IF EXISTS `update_workers`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_workers`()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_id INT;
  DECLARE v_end_date DATE;
  DECLARE v_start_date DATE;

  DECLARE worker_contracts CURSOR FOR 
    SELECT id FROM workers;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN worker_contracts;
  read_loop: LOOP
    FETCH worker_contracts INTO v_id;
    IF done THEN
      LEAVE read_loop;
    END IF;
  SET @end_date = (select end_date_2 from worker_contracts where worker_id = v_id order by start_date desc LIMIT 1);
  SET v_end_date = @end_date;
  SET @start_date = (select start_date from worker_contracts where worker_id = v_id order by start_date ASC LIMIT 1);
  SET v_start_date = @start_date;
  UPDATE workers SET end_date = v_end_date, start_date = v_start_date WHERE id = v_id;
    
  END LOOP read_loop;
  CLOSE worker_contracts;

END $$

DELIMITER ;