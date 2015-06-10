DELIMITER $$

DROP PROCEDURE IF EXISTS `ACCUMULATE_MICRO`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ACCUMULATE_MICRO`(IN vi_cost_center_id INT, IN vi_end_date CHAR(10))
BEGIN
  CREATE TEMPORARY TABLE sumarizado(
  `article_code` varchar(20) NOT NULL,
  `article_name` varchar(500) NOT NULL,
  `article_unit` varchar(40) NOT NULL,
  `programado_specific_lvl_1` varchar(255) NOT NULL  DEFAULT '0',
  `meta_specific_lvl_1` varchar(255) NOT NULL DEFAULT '0',
  `real_specific_lvl_1` varchar(255) NOT NULL DEFAULT '0',
  `valorizado_specific_lvl_1` varchar(255) NOT NULL DEFAULT '0',
  `valor_ganado_specific_lvl_1` varchar(255) NOT NULL DEFAULT '0',
  `measured_programado` varchar(255) DEFAULT NULL  DEFAULT '0',
  `measured_meta` varchar(255) DEFAULT NULL  DEFAULT '0',
  `measured_real` varchar(255) DEFAULT NULL  DEFAULT '0',
  `measured_valorizado` varchar(255) DEFAULT NULL  DEFAULT '0',
  `measured_valor_ganado` varchar(255) DEFAULT NULL  DEFAULT '0',
  `fase_cod_padre` varchar(255) DEFAULT NULL,
  `fase_cod_padre_nombre` varchar(255) DEFAULT NULL,
  `fase_cod_hijo` varchar(255) DEFAULT NULL,
  `fase_cod_hijo_nombre` varchar(255) DEFAULT NULL,
  `sector_cod_padre` varchar(255) DEFAULT NULL,
  `sector_cod_padre_nombre` varchar(255) DEFAULT NULL,
  `sector_cod_hijo` varchar(255) DEFAULT NULL,
  `sector_cod_hijo_nombre` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `working_group_id` int(11) NOT NULL   
  );
  
  SET @flag = (SELECT LAST_DAY(start_date) FROM cost_centers WHERE id = vi_cost_center_id);

  IF @flag < vi_end_date THEN 
    set @accum = CONCAT("INSERT INTO sumarizado(
      article_code, article_name, article_unit, 
      programado_specific_lvl_1, meta_specific_lvl_1, real_specific_lvl_1, valorizado_specific_lvl_1, valor_ganado_specific_lvl_1, 
      measured_programado, measured_meta, measured_real, measured_valorizado, measured_valor_ganado, 
      fase_cod_padre, fase_cod_padre_nombre, fase_cod_hijo, fase_cod_hijo_nombre, 
      sector_cod_padre, sector_cod_padre_nombre, sector_cod_hijo, sector_cod_hijo_nombre, 
      type, working_group_id) SELECT article_code, article_name, article_unit, programado_specific_lvl_1, meta_specific_lvl_1, real_specific_lvl_1, valorizado_specific_lvl_1, valor_ganado_specific_lvl_1, measured_programado, measured_meta, measured_real, measured_valorizado, measured_valor_ganado, fase_cod_padre, fase_cod_padre_nombre, fase_cod_hijo, fase_cod_hijo_nombre, sector_cod_padre, sector_cod_padre_nombre, sector_cod_hijo, sector_cod_hijo_nombre, type, working_group_id FROM system_bi.acc_actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_end_date - INTERVAL 1.month, '%m%Y'));
    PREPARE stmt FROM @accum;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END IF;

  set @sqla = CONCAT("INSERT INTO sumarizado(
    article_code, article_name, article_unit, 
    programado_specific_lvl_1, meta_specific_lvl_1, real_specific_lvl_1, valorizado_specific_lvl_1, valor_ganado_specific_lvl_1, 
    measured_programado, measured_meta, measured_real, measured_valorizado, measured_valor_ganado, 
    fase_cod_padre, fase_cod_padre_nombre, fase_cod_hijo, fase_cod_hijo_nombre, 
    sector_cod_padre, sector_cod_padre_nombre, sector_cod_hijo, sector_cod_hijo_nombre, 
    type, working_group_id) SELECT article_code, article_name, article_unit, programado_specific_lvl_1, meta_specific_lvl_1, real_specific_lvl_1, valorizado_specific_lvl_1, valor_ganado_specific_lvl_1, measured_programado, measured_meta, measured_real, measured_valorizado, measured_valor_ganado, fase_cod_padre, fase_cod_padre_nombre, fase_cod_hijo, fase_cod_hijo_nombre, sector_cod_padre, sector_cod_padre_nombre, sector_cod_hijo, sector_cod_hijo_nombre, type, working_group_id FROM system_bi.actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_end_date, '%m%Y'));
  PREPARE stmt2 FROM @sqla;
  EXECUTE stmt2;
  DEALLOCATE PREPARE stmt2;
  SET @insert = CONCAT("INSERT INTO system_bi.acc_actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_end_date, '%m%Y'),"(
    article_code, article_name, article_unit, 
    programado_specific_lvl_1, meta_specific_lvl_1, real_specific_lvl_1, valorizado_specific_lvl_1, valor_ganado_specific_lvl_1, 
    measured_programado, measured_meta, measured_real, measured_valorizado, measured_valor_ganado, 
    fase_cod_padre, fase_cod_padre_nombre, fase_cod_hijo, fase_cod_hijo_nombre, 
    sector_cod_padre, sector_cod_padre_nombre, sector_cod_hijo, sector_cod_hijo_nombre, 
    type, working_group_id) SELECT
    article_code, article_name, article_unit, 
    SUM(programado_specific_lvl_1), SUM(meta_specific_lvl_1), SUM(real_specific_lvl_1), SUM(valorizado_specific_lvl_1), SUM(valor_ganado_specific_lvl_1), 
    SUM(measured_programado), SUM(measured_meta), SUM(measured_real), SUM(measured_valorizado), SUM(measured_valor_ganado), 
    fase_cod_padre, fase_cod_padre_nombre, fase_cod_hijo, fase_cod_hijo_nombre, 
    sector_cod_padre, sector_cod_padre_nombre, sector_cod_hijo, sector_cod_hijo_nombre, 
    type, working_group_id FROM sumarizado  GROUP BY article_code, fase_cod_hijo, sector_cod_hijo, working_group_id");
  PREPARE stmt3 FROM @insert;
  EXECUTE stmt3;
  DEALLOCATE PREPARE stmt3;
  DROP TEMPORARY TABLE sumarizado;
END $$
DELIMITER ;


DELIMITER $$

DROP PROCEDURE IF EXISTS `ACCUMULATE_PROVISION`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ACCUMULATE_PROVISION`(IN vi_cost_center_id INT, IN vi_end_date CHAR(10))
BEGIN
  CREATE TEMPORARY TABLE sumarizado(
  `article_code` varchar(20) NOT NULL,
  `article_name` varchar(500) NOT NULL,
  `article_unit` varchar(40) NOT NULL,
  `consumed` varchar(255) NOT NULL DEFAULT '0',
  `fase_cod_padre` char(20) DEFAULT NULL,
  `fase_cod_padre_nombre` char(20) DEFAULT NULL,
  `fase_cod_hijo` char(20) DEFAULT NULL,
  `fase_cod_hijo_nombre` char(20) DEFAULT NULL
  );

  SET @flag = (SELECT LAST_DAY(start_date) FROM cost_centers WHERE id = vi_cost_center_id);

  IF @flag < vi_end_date THEN  
    set @accum = CONCAT("INSERT INTO sumarizado(article_code, article_name, article_unit, consumed, fase_cod_padre, fase_cod_padre_nombre, fase_cod_hijo, fase_cod_hijo_nombre)
      SELECT article_code, article_name, article_unit, consumed, fase_cod_padre, fase_cod_padre_nombre, fase_cod_hijo, fase_cod_hijo_nombre
      FROM system_bi.acc_projection_micro_",vi_cost_center_id,"_",DATE_FORMAT(vi_end_date - INTERVAL 1.month, '%m%Y'));
    PREPARE stmt FROM @accum;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END IF;

  set @sqla = CONCAT("INSERT INTO sumarizado(article_code, article_name, article_unit, consumed, fase_cod_padre, fase_cod_padre_nombre, fase_cod_hijo, fase_cod_hijo_nombre)
    SELECT article_code, article_name, article_unit, consumed, fase_cod_padre, fase_cod_padre_nombre, fase_cod_hijo, fase_cod_hijo_nombre FROM system_bi.projection_micro_",vi_cost_center_id,"_",DATE_FORMAT(vi_end_date, '%m%Y'));
  PREPARE stmt2 FROM @sqla;
  EXECUTE stmt2;
  DEALLOCATE PREPARE stmt2;
  SET @insert = CONCAT("INSERT INTO system_bi.acc_projection_micro_",vi_cost_center_id,"_",DATE_FORMAT(vi_end_date, '%m%Y'),"(article_code, article_name, article_unit, consumed, fase_cod_padre, fase_cod_padre_nombre, fase_cod_hijo, fase_cod_hijo_nombre) SELECT
    article_code, article_name, article_unit, SUM(consumed), fase_cod_padre, fase_cod_padre_nombre, fase_cod_hijo, fase_cod_hijo_nombre FROM sumarizado  GROUP BY article_code, fase_cod_hijo");
  PREPARE stmt3 FROM @insert;
  EXECUTE stmt3;
  DEALLOCATE PREPARE stmt3;
  DROP TEMPORARY TABLE sumarizado;
END $$
DELIMITER ;