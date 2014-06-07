DELIMITER $$
--
-- Functions
--

DROP FUNCTION IF EXISTS `getPartWork`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `getPartWork`(start_date DATE, end_date DATE, cost_center_id INT) RETURNS float
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_total FLOAT; 
  DECLARE v_sum FLOAT;
  DECLARE quantity_cursor CURSOR FOR 
    SELECT pwd.bill_of_quantitties*si.price as `total`
    FROM `part_works` pw, `part_work_details` pwd, `articles` art, `subcontract_inputs` si
    WHERE pw.date_of_creation BETWEEN start_date AND end_date
  AND pw.id = pwd.part_work_id
  AND pwd.article_id = art.id
  AND si.article_id = pwd.article_id
  AND pw.cost_center_id = cost_center_id;
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

DROP FUNCTION IF EXISTS `getPartWork2`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `getPartWork2`(end_date DATE, cost_center_id INT) RETURNS float
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_total FLOAT; 
  DECLARE v_sum FLOAT;
  DECLARE quantity_cursor CURSOR FOR 
    SELECT pwd.bill_of_quantitties*si.price as `total`
    FROM `part_works` pw, `part_work_details` pwd, `articles` art, `subcontract_inputs` si
    WHERE pw.date_of_creation < end_date
  AND pw.id = pwd.part_work_id
  AND pwd.article_id = art.id
  AND si.article_id = pwd.article_id
  AND pw.cost_center_id = cost_center_id;
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

DROP FUNCTION IF EXISTS `partEquipment`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `partEquipment`(start_date DATE, end_date DATE, cost_center_id INT, phase_id INT, phase_id2 INT) RETURNS float
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_total FLOAT; 
  DECLARE v_sum FLOAT;
  DECLARE quantity_cursor CURSOR FOR 
    SELECT poed.effective_hours*si.price as `total`
    FROM `part_of_equipments` poe, `part_of_equipment_details` poed, `articles` art, `subcontract_inputs` si
    WHERE poe.date BETWEEN start_date AND end_date
  AND poe.id = poed.part_of_equipment_id
  AND poe.equipment_id = art.id
  AND si.article_id = poe.equipment_id
  AND poe.cost_center_id = cost_center_id
  AND poed.phase_id BETWEEN phase_id AND phase_id2;
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

DROP FUNCTION IF EXISTS `partEquipment2`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `partEquipment2`(end_date DATE, cost_center_id INT, phase_id INT, phase_id2 INT) RETURNS float
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_total FLOAT; 
  DECLARE v_sum FLOAT;
  DECLARE quantity_cursor CURSOR FOR 
    SELECT poed.effective_hours*si.price as `total`
    FROM `part_of_equipments` poe, `part_of_equipment_details` poed, `articles` art, `subcontract_inputs` si
    WHERE poe.date < end_date
  AND poe.id = poed.part_of_equipment_id
  AND poe.equipment_id = art.id
  AND si.article_id = poe.equipment_id
  AND poe.cost_center_id = cost_center_id
  AND poed.phase_id BETWEEN phase_id AND phase_id2;
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

DROP FUNCTION IF EXISTS `partPeople`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `partPeople`(start_date DATE, end_date DATE, cost_center_id INT, phase_id INT, phase_id2 INT) RETURNS float
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_total FLOAT; 
  DECLARE v_sum FLOAT;
  DECLARE quantity_cursor CURSOR FOR 
    SELECT (ppd.normal_hours*cow.normal_price)+(ppd.he_60*cow.he_60_price)+(ppd.he_100*cow.he_100_price) as `total`
    FROM `part_people` pp, `part_person_details` ppd, `articles` art, `workers` wo, `category_of_workers` cow
    WHERE pp.date_of_creation BETWEEN start_date AND end_date
  AND pp.id = ppd.part_person_id
  AND ppd.worker_id = wo.id
  AND wo.article_id = art.id
  AND art.id = cow.article_id
  AND pp.cost_center_id = cost_center_id
  AND ppd.phase_id BETWEEN phase_id AND phase_id2;
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

DROP FUNCTION IF EXISTS `partPeople2`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `partPeople2`(end_date DATE, cost_center_id INT, phase_id INT, phase_id2 INT) RETURNS float
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_total FLOAT; 
  DECLARE v_sum FLOAT;
  DECLARE quantity_cursor CURSOR FOR 
    SELECT (ppd.normal_hours*cow.normal_price)+(ppd.he_60*cow.he_60_price)+(ppd.he_100*cow.he_100_price) as `total`
    FROM `part_people` pp, `part_person_details` ppd, `articles` art, `workers` wo, `category_of_workers` cow
    WHERE pp.date_of_creation < end_date
  AND pp.id = ppd.part_person_id
  AND ppd.worker_id = wo.id
  AND wo.article_id = art.id
  AND art.id = cow.article_id
  AND pp.cost_center_id = cost_center_id
  AND ppd.phase_id BETWEEN phase_id AND phase_id2;
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

DROP FUNCTION IF EXISTS `orderOfService`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `orderOfService`(start_date DATE, end_date DATE, cost_center_id INT, phase_id INT, phase_id2 INT) RETURNS float
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_total FLOAT; 
  DECLARE v_sum FLOAT;
  DECLARE quantity_cursor CURSOR FOR 
    SELECT oosd.unit_price_igv as `total`
    FROM `order_of_services` oos, `order_of_service_details` oosd 
    WHERE oos.date_of_service BETWEEN start_date AND end_date
  AND oosd.order_of_service_id = oos.id
  AND oos.cost_center_id = cost_center_id
  AND oosd.phase_id BETWEEN phase_id AND phase_id2;
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

DROP FUNCTION IF EXISTS `orderOfService2`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `orderOfService2`(end_date DATE, cost_center_id INT, phase_id INT, phase_id2 INT) RETURNS float
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_total FLOAT; 
  DECLARE v_sum FLOAT;
  DECLARE quantity_cursor CURSOR FOR 
    SELECT oosd.unit_price_igv as `total`
    FROM `order_of_services` oos, `order_of_service_details` oosd 
    WHERE oos.date_of_service < end_date
  AND oosd.order_of_service_id = oos.id
  AND oos.cost_center_id = cost_center_id
  AND oosd.phase_id BETWEEN phase_id AND phase_id2;
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

DROP FUNCTION IF EXISTS `scValuations`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `scValuations`(start_date DATE, end_date DATE, cost_center_id INT) RETURNS float
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_total FLOAT; 
  DECLARE v_sum FLOAT;
  DECLARE quantity_cursor CURSOR FOR 
    SELECT sc.net_payment as `total`
    FROM `sc_valuations` sc
    WHERE sc.start_date BETWEEN start_date AND end_date
  AND sc.end_date BETWEEN start_date AND end_date
  AND sc.cost_center_id = cost_center_id;
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

DROP FUNCTION IF EXISTS `scValuations2`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `scValuations2`(end_date DATE, cost_center_id INT) RETURNS float
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_total FLOAT; 
  DECLARE v_sum FLOAT;
  DECLARE quantity_cursor CURSOR FOR 
    SELECT sc.net_payment as `total`
    FROM `sc_valuations` sc
    WHERE sc.end_date < end_date
  AND sc.cost_center_id = cost_center_id;
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