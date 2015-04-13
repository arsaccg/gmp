DELIMITER $$

DROP PROCEDURE IF EXISTS `update_contracts`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `update_contracts`()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_id INT;
  DECLARE v_end_date DATE;

  DECLARE worker_contracts CURSOR FOR 
    SELECT id, IFNULL(end_date_2,end_date) FROM worker_contracts WHERE status = 1;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN worker_contracts;
  read_loop: LOOP
    FETCH worker_contracts INTO v_id, v_end_date;
    IF done THEN
      LEAVE read_loop;
    END IF;
    IF v_end_date < DATE_ADD(CURDATE(), INTERVAL -1 DAY) THEN
      UPDATE worker_contracts SET status = 0 WHERE id = v_id;
    END IF;
  END LOOP read_loop;
  CLOSE worker_contracts;

END $$

DELIMITER ;