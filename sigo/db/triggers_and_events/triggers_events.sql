DELIMITER $$

DROP TRIGGER IF EXISTS `after_article_insert`$$
CREATE TRIGGER `after_article_insert`
  AFTER INSERT ON `system_sigo_dev`.`articles`
  FOR EACH ROW BEGIN

  INSERT INTO `system_bi`.`articles`
  SELECT * FROM `system_sigo_dev`.`articles` WHERE id = New.id;
END$$

DROP TRIGGER IF EXISTS `before_article_update`$$
CREATE TRIGGER `before_article_update`
  BEFORE UPDATE ON `system_sigo_dev`.`articles`
  FOR EACH ROW BEGIN

  UPDATE `system_bi`.`articles`
    SET name = NEW.name,
      description = NEW.description,
      code = NEW.code,
      type_of_article_id = NEW.type_of_article_id,
      unit_of_measurement_id = NEW.unit_of_measurement_id,
      category_id = NEW.category_id
  WHERE code = OLD.code;
END$$

DROP TRIGGER IF EXISTS `after_category_insert`$$
CREATE TRIGGER `after_category_insert`
  AFTER INSERT ON `system_sigo_dev`.`categories`
  FOR EACH ROW BEGIN

  INSERT INTO `system_bi`.`categories`
  SELECT * FROM `system_sigo_dev`.`categories` WHERE id = New.id;
END$$

DROP TRIGGER IF EXISTS `before_category_update`$$
CREATE TRIGGER `before_category_update`
  BEFORE UPDATE ON `system_sigo_dev`.`categories`
  FOR EACH ROW BEGIN

  UPDATE `system_bi`.`categories`
    SET name = NEW.name,
      code = NEW.code
  WHERE id = OLD.id;
END$$

--
-- Events
--

-- SET GLOBAL event_scheduler = ON;
CREATE EVENT IF NOT EXISTS `import_actual_values` 
	ON SCHEDULE 
	  EVERY 1 DAY ON COMPLETION PRESERVE ENABLE 
	  STARTS '2015-01-01 00:00:10'
	  -- EVERY 5 SECOND
	  COMMENT 'Import Actual Values from ERP to BI'
	DO
    -- SELECT Testing for Inserting Table
		INSERT INTO `system_bi`.`actual_values_january`
		SELECT null, 'code', 'name', 'unit', '123', '321', '312', '453', '123', '321', '312', '453', '123', '321', '312', '453' FROM DUAL

DELIMITER ;