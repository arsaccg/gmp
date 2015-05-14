DELIMITER $$

DROP PROCEDURE IF EXISTS `SHOWME_MICRO_VALUES_BI`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SHOWME_MICRO_VALUES_BI`(IN vi_cost_center_id INT, IN vi_start_date CHAR(10), IN vi_end_date CHAR(10))
BEGIN
  DECLARE done INT DEFAULT FALSE;

  DECLARE v_article_code TEXT;
  DECLARE v_article_name TEXT;
  DECLARE v_article_unit TEXT;
  DECLARE v_phase_code_padre TEXT;
  DECLARE v_phase_code_hijo TEXT;
  DECLARE v_sector_code_padre TEXT;
  DECLARE v_sector_code_hijo TEXT;
  DECLARE v_working_group INTEGER;
  DECLARE v_quantity FLOAT(10,2);
  DECLARE v_amount FLOAT(10,2);

  -- COSTO DIRECTO / VALORIZADO - VENTA
  BLOCKVV: BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE ibi_done INT DEFAULT FALSE;
    DECLARE insumos_mo INT DEFAULT FALSE;
    DECLARE insumos_material INT DEFAULT FALSE;
    DECLARE insumos_equipment INT DEFAULT FALSE;
    DECLARE insumos_subcontract INT DEFAULT FALSE;
    DECLARE insumos_service INT DEFAULT FALSE;

    DECLARE v_valorization_id INT;
    DECLARE v_budget_id INT;
    DECLARE v_order CHAR(120);
    DECLARE v_description CHAR(255);
    DECLARE v_measured FLOAT(10,4);

    DECLARE v_phase_cod_padre CHAR(6);
    DECLARE v_phase_cod_padre_name CHAR(200);

    DECLARE v_phase_cod_hijo CHAR(6);
    DECLARE v_phase_cod_hijo_name CHAR(200);

    DECLARE v_partial_mo FLOAT(10,4);
    DECLARE v_amount_mo FLOAT(10,4);
    DECLARE v_cod_input_mo CHAR(20);
    DECLARE v_cod_input_mo_name CHAR(20);
    DECLARE v_cod_input_mo_unit CHAR(20);

    DECLARE v_partial_material FLOAT(10,4);
    DECLARE v_amount_material FLOAT(10,4);
    DECLARE v_cod_input_material CHAR(20);
    DECLARE v_cod_input_material_name CHAR(20);
    DECLARE v_cod_input_material_unit CHAR(20);

    DECLARE v_partial_equipment FLOAT(10,4);
    DECLARE v_amount_equipment FLOAT(10,4);
    DECLARE v_cod_input_equipment CHAR(20);
    DECLARE v_cod_input_equipment_name CHAR(20);
    DECLARE v_cod_input_equipment_unit CHAR(20);

    DECLARE v_partial_subcontract FLOAT(10,4);
    DECLARE v_amount_subcontract FLOAT(10,4);
    DECLARE v_cod_input_subcontract CHAR(20);
    DECLARE v_cod_input_subcontract_name CHAR(20);
    DECLARE v_cod_input_subcontract_unit CHAR(20);

    DECLARE v_partial_service FLOAT(10,4);
    DECLARE v_amount_service FLOAT(10,4);
    DECLARE v_cod_input_service CHAR(20);
    DECLARE v_cod_input_service_name CHAR(20);
    DECLARE v_cod_input_service_unit CHAR(20);

    DECLARE valorizations CURSOR FOR
    SELECT v.id, b.id 
    FROM valorizations v, budgets b 
    WHERE b.cost_center_id = vi_cost_center_id -- DATO DE ENTRADA
    AND b.type_of_budget = 1
    AND b.id = v.budget_id
    AND v.valorization_date BETWEEN vi_start_date AND vi_end_date; -- DATOS DE ENTRADA
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN valorizations;
    read_loop: LOOP
      FETCH valorizations INTO v_valorization_id, v_budget_id;
    IF done THEN
      LEAVE read_loop;
    END IF;

    -- MONTOS VALORIZADOS
    BLOCK: BEGIN

      DECLARE itembybudgets CURSOR FOR
      SELECT rv.order, description, con_measured FROM report_valorizations rv WHERE valorization_id = v_valorization_id AND con_measured IS NOT NULL;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET ibi_done = TRUE;
    
      OPEN itembybudgets;
      read_loop_ibb: LOOP
      FETCH itembybudgets INTO v_order, v_description, v_measured;
      IF ibi_done THEN
        LEAVE read_loop_ibb;
      END IF;

      SET @i_identify = (SELECT p.id FROM itembywbses ibw, wbsitems wi, phases p WHERE ibw.wbsitem_id = wi.id AND p.code > '0___' AND p.code < '89__' AND wi.phase_id = p.id AND ibw.budget_id = v_budget_id AND ibw.order_budget LIKE v_order GROUP BY p.id);

      IF @i_identify IS NOT NULL THEN

        -- GENERAL
        SELECT LEFT(p.code, 2), p.code, p.name INTO v_phase_cod_padre, v_phase_cod_hijo, v_phase_cod_hijo_name FROM phases p WHERE p.id = @i_identify;
        SELECT p.name INTO v_phase_cod_padre_name FROM phases p WHERE p.code LIKE v_phase_cod_padre;
        -- GENERAL
        
        BLOCKMO: BEGIN
          DECLARE manoObraInsumos CURSOR FOR
            SELECT SUM( ibi.quantity * ibi.price * IFNULL(ib.measured,0) ) as 'parcial', SUM( ibi.quantity * IFNULL(ib.measured,0) ) as 'cantidad',ibi.cod_input 
            FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
            WHERE ibi.cod_input LIKE '01%' 
            AND ibi.budget_id = v_budget_id 
            AND ib.budget_id = v_budget_id 
            AND ibi.`order` LIKE CONCAT(v_order, '%') 
            AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ) 
            GROUP BY ibi.cod_input;
          DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_mo = TRUE;

          OPEN manoObraInsumos;
            read_loop_mo: LOOP
              FETCH manoObraInsumos INTO v_partial_mo, v_amount_mo, v_cod_input_mo;
              IF insumos_mo THEN
                LEAVE read_loop_mo;
              END IF;

              SELECT a.name, u.name INTO v_cod_input_mo_name, v_cod_input_mo_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_mo AND a.unit_of_measurement_id = u.id;

              SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
              "`(`article_code`, `article_name`, `article_unit`, `valorizado_specific_lvl_1`, `measured_valorizado`, `fase_cod_padre`, `fase_cod_padre_nombre`, `fase_cod_hijo`, `fase_cod_hijo_nombre`, `type`, `insertion_date`)
              VALUES ('",v_cod_input_mo, "','", v_cod_input_mo_name, "','", v_cod_input_mo_unit, "','", v_partial_mo, "','", v_amount_mo, "','", v_phase_cod_padre,"','",v_phase_cod_padre_name,"','",v_phase_cod_hijo, "','", v_phase_cod_hijo_name, "','", 'CD', "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
              PREPARE stmt FROM @SQL;
              EXECUTE stmt;
              DEALLOCATE PREPARE stmt;
            END LOOP read_loop_mo;
          CLOSE manoObraInsumos;
        END BLOCKMO;

        BLOCKMATERIAL: BEGIN
          DECLARE materialInsumos CURSOR FOR
            SELECT SUM( ibi.quantity * ibi.price * IFNULL(ib.measured,0) ) as 'parcial', SUM( ibi.quantity * IFNULL(ib.measured,0) ) as 'cantidad',ibi.cod_input 
            FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
            WHERE ibi.cod_input LIKE '02%' 
            AND ibi.budget_id = v_budget_id 
            AND ib.budget_id = v_budget_id 
            AND ibi.`order` LIKE CONCAT(v_order, '%') 
            AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ) 
            GROUP BY ibi.cod_input;
          DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_material = TRUE;

          OPEN materialInsumos;
            read_loop_material: LOOP
              FETCH materialInsumos INTO v_partial_material, v_amount_material, v_cod_input_material;
              IF insumos_material THEN
                LEAVE read_loop_material;
              END IF;

              SELECT a.name, u.name INTO v_cod_input_material_name, v_cod_input_material_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_material AND a.unit_of_measurement_id = u.id;

              SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
                "`(`article_code`, `article_name`, `article_unit`, `valorizado_specific_lvl_1`, `measured_valorizado`, `fase_cod_padre`, `fase_cod_padre_nombre`, `fase_cod_hijo`, `fase_cod_hijo_nombre`, `type`, `insertion_date`)
                VALUES ('",v_cod_input_material, "','", v_cod_input_material_name, "','", v_cod_input_material_unit, "','", v_partial_material, "','", v_amount_material, "','", v_phase_cod_padre, "','",v_phase_cod_padre_name,"','",v_phase_cod_hijo, "','", v_phase_cod_hijo_name, "','", 'CD', "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
              PREPARE stmt FROM @SQL;
              EXECUTE stmt;
              DEALLOCATE PREPARE stmt;

            END LOOP read_loop_material;
          CLOSE materialInsumos;
        END BLOCKMATERIAL;

        BLOCKEQUIPMENT: BEGIN
          DECLARE equiposInsumos CURSOR FOR
            SELECT SUM( ibi.quantity * ibi.price * IFNULL(ib.measured,0) ) as 'parcial', SUM( ibi.quantity * IFNULL(ib.measured,0) ) as 'cantidad',ibi.cod_input 
            FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
            WHERE ibi.cod_input LIKE '03%' 
            AND ibi.budget_id = v_budget_id 
            AND ib.budget_id = v_budget_id 
            AND ibi.`order` LIKE CONCAT(v_order, '%') 
            AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ) 
            GROUP BY ibi.cod_input;
          DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_equipment = TRUE;

          OPEN equiposInsumos;
            read_loop_equipment: LOOP
              FETCH equiposInsumos INTO v_partial_equipment, v_amount_equipment, v_cod_input_equipment;
              IF insumos_equipment THEN
                LEAVE read_loop_equipment;
              END IF;

              SELECT a.name, u.name INTO v_cod_input_equipment_name, v_cod_input_equipment_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_equipment AND a.unit_of_measurement_id = u.id;

              SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
                "`(`article_code`, `article_name`, `article_unit`, `valorizado_specific_lvl_1`, `measured_valorizado`, `fase_cod_padre`, `fase_cod_padre_nombre`, `fase_cod_hijo`, `fase_cod_hijo_nombre`, `type`, `insertion_date`)
                VALUES ('",v_cod_input_equipment, "','", v_cod_input_equipment_name, "','", v_cod_input_equipment_unit, "','", v_partial_equipment, "','", v_amount_equipment, "','", v_phase_cod_padre, "','", v_phase_cod_padre_name, "','", v_phase_cod_hijo, "','", v_phase_cod_hijo_name, "','", 'CD', "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
              PREPARE stmt FROM @SQL;
              EXECUTE stmt;
              DEALLOCATE PREPARE stmt;

            END LOOP read_loop_equipment;
          CLOSE equiposInsumos;
        END BLOCKEQUIPMENT;

        BLOCKSUBCONTRACT: BEGIN
          DECLARE subcontratosInsumos CURSOR FOR
            SELECT SUM( ibi.quantity * ibi.price * IFNULL(ib.measured,0) ) as 'parcial', SUM( ibi.quantity * IFNULL(ib.measured,0) ) as 'cantidad',ibi.cod_input 
            FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
            WHERE ibi.cod_input LIKE '04%' 
            AND ibi.budget_id = v_budget_id 
            AND ib.budget_id = v_budget_id 
            AND ibi.`order` LIKE CONCAT(v_order, '%') 
            AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ) 
            GROUP BY ibi.cod_input;
          DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_subcontract = TRUE;

          OPEN subcontratosInsumos;
            read_loop_subcontracts: LOOP
              FETCH subcontratosInsumos INTO v_partial_subcontract, v_amount_subcontract, v_cod_input_subcontract;
              IF insumos_subcontract THEN
                LEAVE read_loop_subcontracts;
              END IF;

              SELECT a.name, u.name INTO v_cod_input_subcontract_name, v_cod_input_subcontract_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_subcontract AND a.unit_of_measurement_id = u.id;

              SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
                "`(`article_code`, `article_name`, `article_unit`, `valorizado_specific_lvl_1`, `measured_valorizado`, `fase_cod_padre`, `fase_cod_padre_nombre`, `fase_cod_hijo`, `fase_cod_hijo_nombre`, `type`, `insertion_date`)
                VALUES ('",v_cod_input_subcontract, "','", v_cod_input_subcontract_name, "','", v_cod_input_subcontract_unit, "','", v_partial_subcontract, "','", v_amount_subcontract, "','", v_phase_cod_padre,"','",v_phase_cod_padre_name,"','",v_phase_cod_hijo, "','", v_phase_cod_hijo_name, "','", 'CD', "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
              PREPARE stmt FROM @SQL;
              EXECUTE stmt;
              DEALLOCATE PREPARE stmt;

            END LOOP read_loop_subcontracts;
          CLOSE subcontratosInsumos;
        END BLOCKSUBCONTRACT;

        BLOCKSERVICE: BEGIN
          DECLARE servicioInsumos CURSOR FOR
            SELECT SUM( ibi.quantity * ibi.price * IFNULL(ib.measured,0) ) as 'parcial', SUM( ibi.quantity * IFNULL(ib.measured,0) ) as 'cantidad',ibi.cod_input 
            FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
            WHERE ibi.cod_input LIKE '05%' 
            AND ibi.budget_id = v_budget_id 
            AND ib.budget_id = v_budget_id 
            AND ibi.`order` LIKE CONCAT(v_order, '%') 
            AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ) 
            GROUP BY ibi.cod_input;
          DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_service = TRUE;

          OPEN servicioInsumos;
            read_loop_service: LOOP
              FETCH servicioInsumos INTO v_partial_service, v_amount_service, v_cod_input_service;
              IF insumos_service THEN
                LEAVE read_loop_service;
              END IF;

              SELECT a.name, u.name INTO v_cod_input_service_name, v_cod_input_service_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_service AND a.unit_of_measurement_id = u.id;

              SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
                "`(`article_code`, `article_name`, `article_unit`, `valorizado_specific_lvl_1`, `measured_valorizado`, `fase_cod_padre`, `fase_cod_padre_nombre`, `fase_cod_hijo`, `fase_cod_hijo_nombre`, `type`, `insertion_date`)
                VALUES ('",v_cod_input_service, "','", v_cod_input_service_name, "','", v_cod_input_service_unit, "','", v_partial_service, "','", v_amount_service, "','", v_phase_cod_padre, "','", v_phase_cod_padre_name,"','",v_phase_cod_hijo, "','", v_phase_cod_hijo_name, "','", 'CD', "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
              PREPARE stmt FROM @SQL;
              EXECUTE stmt;
              DEALLOCATE PREPARE stmt;

            END LOOP read_loop_service;
          CLOSE servicioInsumos;
        END BLOCKSERVICE;

      END IF;

      END LOOP read_loop_ibb;
      CLOSE itembybudgets;

    END BLOCK;

    END LOOP read_loop;
    CLOSE valorizations;

  END BLOCKVV;

  -- COSTO DIRECTO / META
  BLOCKCDM: BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE insumos_mo INT DEFAULT FALSE;
    DECLARE insumos_material INT DEFAULT FALSE;
    DECLARE insumos_equipment INT DEFAULT FALSE;
    DECLARE insumos_subcontract INT DEFAULT FALSE;
    DECLARE insumos_service INT DEFAULT FALSE;

    DECLARE v_itembybudget_id INT;
    DECLARE v_budget_id INT;
    DECLARE v_order CHAR(120);
    DECLARE v_sector_id INT;
    DECLARE v_working_group_id INT;

    DECLARE v_phase_cod_padre CHAR(6);
    DECLARE v_phase_cod_padre_name CHAR(200);

    DECLARE v_phase_cod_hijo CHAR(6);
    DECLARE v_phase_cod_hijo_name CHAR(200);

    DECLARE v_sector_cod_padre CHAR(6);
    DECLARE v_sector_cod_padre_name CHAR(6);

    DECLARE v_sector_cod_hijo CHAR(6);
    DECLARE v_sector_cod_hijo_name CHAR(6);

    DECLARE v_partial_mo FLOAT(10,4);
    DECLARE v_amount_mo FLOAT(10,4);
    DECLARE v_cod_input_mo CHAR(20);
    DECLARE v_cod_input_mo_name CHAR(20);
    DECLARE v_cod_input_mo_unit CHAR(20);

    DECLARE v_partial_material FLOAT(10,4);
    DECLARE v_amount_material FLOAT(10,4);
    DECLARE v_cod_input_material CHAR(20);
    DECLARE v_cod_input_material_name CHAR(20);
    DECLARE v_cod_input_material_unit CHAR(20);

    DECLARE v_partial_equipment FLOAT(10,4);
    DECLARE v_amount_equipment FLOAT(10,4);
    DECLARE v_cod_input_equipment CHAR(20);
    DECLARE v_cod_input_equipment_name CHAR(20);
    DECLARE v_cod_input_equipment_unit CHAR(20);

    DECLARE v_partial_subcontract FLOAT(10,4);
    DECLARE v_amount_subcontract FLOAT(10,4);
    DECLARE v_cod_input_subcontract CHAR(20);
    DECLARE v_cod_input_subcontract_name CHAR(20);
    DECLARE v_cod_input_subcontract_unit CHAR(20);

    DECLARE v_partial_service FLOAT(10,4);
    DECLARE v_amount_service FLOAT(10,4);
    DECLARE v_cod_input_service CHAR(20);
    DECLARE v_cod_input_service_name CHAR(20);
    DECLARE v_cod_input_service_unit CHAR(20);

    DECLARE itembybudgets CURSOR FOR -- ESTO SACA DATOS CON ibb.id REPETIDOS
    SELECT ibb.id, ibb.budget_id, ibb.order, pw.sector_id, pw.working_group_id
    FROM part_works pw, part_work_details pwd, itembybudgets ibb
    WHERE pw.cost_center_id = vi_cost_center_id -- DATOS DE ENTRADA 
    AND pw.date_of_creation BETWEEN vi_start_date AND vi_end_date -- DATOS DE ENTRADA
    AND pw.id = pwd.part_work_id
    AND pwd.itembybudget_id = ibb.id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- MONTOS META
    OPEN itembybudgets;
    read_loop: LOOP
      FETCH itembybudgets INTO v_itembybudget_id, v_budget_id, v_order, v_sector_id, v_working_group_id;
    IF done THEN
        LEAVE read_loop;
      END IF;
    
    SET @i_identify = (SELECT p.id FROM itembywbses ibw, wbsitems wi, phases p WHERE ibw.wbsitem_id = wi.id AND p.code > '0___' AND p.code < '89__' AND wi.phase_id = p.id AND ibw.budget_id = v_budget_id AND ibw.order_budget LIKE v_order GROUP BY p.id);

    IF @i_identify IS NOT NULL THEN
      
      -- GENERAL
      SELECT LEFT(p.code, 2), p.code, p.name INTO v_phase_cod_padre, v_phase_cod_hijo, v_phase_cod_hijo_name FROM phases p WHERE p.id = @i_identify;
      
      SELECT p.name INTO v_phase_cod_padre_name FROM phases p WHERE p.code LIKE v_phase_cod_padre;
      
      SELECT LEFT(s.code, 2), s.code, s.name INTO v_sector_cod_padre, v_sector_cod_hijo, v_sector_cod_hijo_name FROM sectors s WHERE s.id = v_sector_id;
      
      SELECT s.name INTO v_sector_cod_padre_name FROM sectors s WHERE s.code LIKE v_sector_cod_padre LIMIT 1;
      
      -- GENERAL
      BLOCKMO: BEGIN
        DECLARE manoObraInsumos CURSOR FOR
          SELECT SUM( ibi.quantity * ibi.price * IFNULL(ib.measured,0) ) as 'parcial', SUM( ibi.quantity * IFNULL(ib.measured,0) ) as 'cantidad',ibi.cod_input
          FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
          WHERE ibi.cod_input LIKE  '01%' 
          AND ibi.budget_id = v_budget_id 
          AND ib.budget_id = v_budget_id 
          AND ibi.`order` LIKE CONCAT(v_order, '%') 
          AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' )
          GROUP BY ibi.cod_input;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_mo = TRUE;

          OPEN manoObraInsumos;
            read_loop_mo: LOOP
              FETCH manoObraInsumos INTO v_partial_mo, v_amount_mo, v_cod_input_mo;
              IF insumos_mo THEN
                LEAVE read_loop_mo;
              END IF;

              SELECT a.name, u.name INTO v_cod_input_mo_name, v_cod_input_mo_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_mo AND a.unit_of_measurement_id = u.id;

              SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
                "`(`article_code`, `article_name`, `article_unit`, `meta_specific_lvl_1`, `measured_meta`, `fase_cod_padre`, `fase_cod_padre_nombre`, `fase_cod_hijo`, `fase_cod_hijo_nombre`, `sector_cod_padre`, `sector_cod_padre_nombre`, `sector_cod_hijo`, `sector_cod_hijo_nombre`, `type`, `working_group_id`, `insertion_date`)
                VALUES ('",v_cod_input_mo, "','", v_cod_input_mo_name, "','", v_cod_input_mo_unit, "','", v_partial_mo, "','", v_amount_mo, "','", v_phase_cod_padre, "','", v_phase_cod_padre_name,"','",v_phase_cod_hijo, "','", v_phase_cod_hijo_name, "','", v_sector_cod_padre, "','", v_sector_cod_padre_name, "','", v_sector_cod_hijo, "','", v_sector_cod_hijo_name, "','", 'CD', "','", v_working_group_id, "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
              PREPARE stmt FROM @SQL;
              EXECUTE stmt;
              DEALLOCATE PREPARE stmt;

            END LOOP read_loop_mo;
          CLOSE manoObraInsumos;
      END BLOCKMO;
      
      BLOCKMATERIAL: BEGIN
        DECLARE materialInsumos CURSOR FOR
          SELECT SUM( ibi.quantity * ibi.price * IFNULL(ib.measured,0) ) as 'parcial', SUM( ibi.quantity * IFNULL(ib.measured,0) ) as 'cantidad',ibi.cod_input
          FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
          WHERE ibi.cod_input LIKE  '02%' 
          AND ibi.budget_id = v_budget_id 
          AND ib.budget_id = v_budget_id 
          AND ibi.`order` LIKE CONCAT(v_order, '%') 
          AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' )
          GROUP BY ibi.cod_input;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_material = TRUE;

        OPEN materialInsumos;
          read_loop_material: LOOP
            FETCH materialInsumos INTO v_partial_material, v_amount_material, v_cod_input_material;
            IF insumos_material THEN
              LEAVE read_loop_material;
            END IF;

            SELECT a.name, u.name INTO v_cod_input_material_name, v_cod_input_material_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_material AND a.unit_of_measurement_id = u.id;

            SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
              "`(`article_code`, `article_name`, `article_unit`, `meta_specific_lvl_1`, `measured_meta`, `fase_cod_padre`, `fase_cod_padre_nombre`, `fase_cod_hijo`, `fase_cod_hijo_nombre`, `sector_cod_padre`, `sector_cod_padre_nombre`, `sector_cod_hijo`, `sector_cod_hijo_nombre`, `type`, `working_group_id`, `insertion_date`)
              VALUES ('",v_cod_input_material, "','", v_cod_input_material_name, "','", v_cod_input_material_unit, "','", v_partial_material, "','", v_amount_material, "','", v_phase_cod_padre,"','",v_phase_cod_padre_name,"','",v_phase_cod_hijo, "','", v_phase_cod_hijo_name, "','", v_sector_cod_padre, "','", v_sector_cod_padre_name, "','", v_sector_cod_hijo, "','", v_sector_cod_hijo_name, "','", 'CD', "','", v_working_group_id, "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
            PREPARE stmt FROM @SQL;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

          END LOOP read_loop_material;
        CLOSE materialInsumos;
      END BLOCKMATERIAL;

      BLOCKEQUIPMENT: BEGIN
        DECLARE equiposInsumos CURSOR FOR
          SELECT SUM( ibi.quantity * ibi.price * IFNULL(ib.measured,0) ) as 'parcial', SUM( ibi.quantity * IFNULL(ib.measured,0) ) as 'cantidad',ibi.cod_input
          FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
          WHERE ibi.cod_input LIKE  '03%' 
          AND ibi.budget_id = v_budget_id 
          AND ib.budget_id = v_budget_id 
          AND ibi.`order` LIKE CONCAT(v_order, '%') 
          AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' );
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_equipment = TRUE;

          OPEN equiposInsumos;
            read_loop_equipment: LOOP
              FETCH equiposInsumos INTO v_partial_equipment, v_amount_equipment, v_cod_input_equipment;
              IF insumos_equipment THEN
                LEAVE read_loop_equipment;
              END IF;

              SELECT a.name, u.name INTO v_cod_input_equipment_name, v_cod_input_equipment_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_equipment AND a.unit_of_measurement_id = u.id;

              SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
                "`(`article_code`, `article_name`, `article_unit`, `meta_specific_lvl_1`, `measured_meta`, `fase_cod_padre`, `fase_cod_padre_nombre`, `fase_cod_hijo`, `fase_cod_hijo_nombre`, `sector_cod_padre`, `sector_cod_padre_nombre`, `sector_cod_hijo`, `sector_cod_hijo_nombre`, `type`, `working_group_id`, `insertion_date`)
                VALUES ('",v_cod_input_equipment, "','", v_cod_input_equipment_name, "','", v_cod_input_equipment_unit, "','", v_partial_equipment, "','", v_amount_equipment, "','", v_phase_cod_padre, "','", v_phase_cod_padre_name, "','", v_phase_cod_hijo, "','", v_phase_cod_hijo_name, "','", v_sector_cod_padre, "','", v_sector_cod_padre_name, "','", v_sector_cod_hijo, "','", v_sector_cod_hijo_name, "','", 'CD', "','", v_working_group_id, "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
              PREPARE stmt FROM @SQL;
              EXECUTE stmt;
              DEALLOCATE PREPARE stmt;

            END LOOP read_loop_equipment;
          CLOSE equiposInsumos;
      END BLOCKEQUIPMENT;

      BLOCKSUBCONTRACT: BEGIN
        DECLARE subcontratosInsumos CURSOR FOR
          SELECT SUM( ibi.quantity * ibi.price * IFNULL(ib.measured,0) ) as 'parcial', SUM( ibi.quantity * IFNULL(ib.measured,0) ) as 'cantidad',ibi.cod_input
          FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
          WHERE ibi.cod_input LIKE  '04%' 
          AND ibi.budget_id = v_budget_id 
          AND ib.budget_id = v_budget_id 
          AND ibi.`order` LIKE CONCAT(v_order, '%') 
          AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' )
          GROUP BY ibi.cod_input;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_subcontract = TRUE;

        OPEN subcontratosInsumos;
          read_loop_subcontracts: LOOP
            FETCH subcontratosInsumos INTO v_partial_subcontract, v_amount_subcontract, v_cod_input_subcontract;
            IF insumos_subcontract THEN
              LEAVE read_loop_subcontracts;
            END IF;

            SELECT a.name, u.name INTO v_cod_input_subcontract_name, v_cod_input_subcontract_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_subcontract AND a.unit_of_measurement_id = u.id;

            SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
              "`(`article_code`, `article_name`, `article_unit`, `meta_specific_lvl_1`, `measured_meta`, `fase_cod_padre`, `fase_cod_padre_nombre`, `fase_cod_hijo`, `fase_cod_hijo_nombre`, `sector_cod_padre`, `sector_cod_padre_nombre`, `sector_cod_hijo`, `sector_cod_hijo_nombre`, `type`, `working_group_id`, `insertion_date`)
              VALUES ('",v_cod_input_subcontract, "','", v_cod_input_subcontract_name, "','", v_cod_input_subcontract_unit, "','", v_partial_subcontract, "','", v_amount_subcontract, "','", v_phase_cod_padre, "','", v_phase_cod_padre_name,"','",v_phase_cod_hijo, "','", v_phase_cod_hijo_name, "','", v_sector_cod_padre, "','", v_sector_cod_padre_name, "','", v_sector_cod_hijo, "','", v_sector_cod_hijo_name, "','", 'CD', "','", v_working_group_id, "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
            PREPARE stmt FROM @SQL;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

          END LOOP read_loop_subcontracts;
        CLOSE subcontratosInsumos;
      END BLOCKSUBCONTRACT;

      BLOCKSERVICE: BEGIN
        DECLARE servicioInsumos CURSOR FOR
          SELECT SUM( ibi.quantity * ibi.price * IFNULL(ib.measured,0) ) as 'parcial', SUM( ibi.quantity * IFNULL(ib.measured,0) ) as 'cantidad',ibi.cod_input
          FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
          WHERE ibi.cod_input LIKE  '05%' 
          AND ibi.budget_id = v_budget_id 
          AND ib.budget_id = v_budget_id 
          AND ibi.`order` LIKE CONCAT(v_order, '%') 
          AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' )
          GROUP BY ibi.cod_input;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_service = TRUE;

        OPEN servicioInsumos;
          read_loop_service: LOOP
            FETCH servicioInsumos INTO v_partial_service, v_amount_service, v_cod_input_service;
            IF insumos_service THEN
              LEAVE read_loop_service;
            END IF;

            SELECT a.name, u.name INTO v_cod_input_service_name, v_cod_input_service_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_service AND a.unit_of_measurement_id = u.id;

            SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
              "`(`article_code`, `article_name`, `article_unit`, `meta_specific_lvl_1`, `measured_meta`, `fase_cod_padre`, `fase_cod_padre_nombre`, `fase_cod_hijo`, `fase_cod_hijo_nombre`, `sector_cod_padre`, `sector_cod_padre_nombre`, `sector_cod_hijo`, `sector_cod_hijo_nombre`, `type`, `working_group_id`, `insertion_date`)
              VALUES ('",v_cod_input_service, "','", v_cod_input_service_name, "','", v_cod_input_service_unit, "','", v_partial_service, "','", v_amount_service, "','", v_phase_cod_padre, "','", v_phase_cod_padre_name, "','", v_phase_cod_hijo, "','", v_phase_cod_hijo_name, "','", v_sector_cod_padre, "','", v_sector_cod_padre_name, "','", v_sector_cod_hijo, "','", v_sector_cod_hijo_name, "','", 'CD', "','", v_working_group_id, "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
            PREPARE stmt FROM @SQL;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

          END LOOP read_loop_service;
        CLOSE servicioInsumos;
      END BLOCKSERVICE;

    END IF;

    END LOOP read_loop;
    CLOSE itembybudgets;

  END BLOCKCDM;

  -- COSTO DIRECTO / VALOR GANADO
  BLOCKCDVG: BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE insumos_mo INT DEFAULT FALSE;
    DECLARE insumos_material INT DEFAULT FALSE;
    DECLARE insumos_equipment INT DEFAULT FALSE;
    DECLARE insumos_subcontract INT DEFAULT FALSE;
    DECLARE insumos_service INT DEFAULT FALSE;

    DECLARE v_itembybudget_id INT;
    DECLARE v_itembybudget_sale_id INT;
    DECLARE v_percentage FLOAT(10,5);
    DECLARE v_bill_of_quantity FLOAT(10,4);
    DECLARE v_sector_id INT;
    DECLARE v_working_group_id INT;
    DECLARE v_budget_id INT;
    DECLARE v_order CHAR(120);

    DECLARE v_sector_cod_padre CHAR(6);
    DECLARE v_sector_cod_padre_name CHAR(6);

    DECLARE v_sector_cod_hijo CHAR(6);
    DECLARE v_sector_cod_hijo_name CHAR(6);

    DECLARE v_partial_mo FLOAT(10,4);
    DECLARE v_amount_mo FLOAT(10,4);
    DECLARE v_cod_input_mo CHAR(20);
    DECLARE v_cod_input_mo_name CHAR(20);
    DECLARE v_cod_input_mo_unit CHAR(20);

    DECLARE v_partial_material FLOAT(10,4);
    DECLARE v_amount_material FLOAT(10,4);
    DECLARE v_cod_input_material CHAR(20);
    DECLARE v_cod_input_material_name CHAR(20);
    DECLARE v_cod_input_material_unit CHAR(20);

    DECLARE v_partial_equipment FLOAT(10,4);
    DECLARE v_amount_equipment FLOAT(10,4);
    DECLARE v_cod_input_equipment CHAR(20);
    DECLARE v_cod_input_equipment_name CHAR(20);
    DECLARE v_cod_input_equipment_unit CHAR(20);

    DECLARE v_partial_subcontract FLOAT(10,4);
    DECLARE v_amount_subcontract FLOAT(10,4);
    DECLARE v_cod_input_subcontract CHAR(20);
    DECLARE v_cod_input_subcontract_name CHAR(20);
    DECLARE v_cod_input_subcontract_unit CHAR(20);

    DECLARE v_partial_service FLOAT(10,4);
    DECLARE v_amount_service FLOAT(10,4);
    DECLARE v_cod_input_service CHAR(20);
    DECLARE v_cod_input_service_name CHAR(20);
    DECLARE v_cod_input_service_unit CHAR(20);

    DECLARE itembybudgets CURSOR FOR
      SELECT pwd.itembybudget_id, ibb.order, ibb.budget_id, pwd.bill_of_quantitties, pw.sector_id, pw.working_group_id 
      FROM part_works pw, part_work_details pwd, itembybudgets ibb
      WHERE pw.cost_center_id = vi_cost_center_id
      AND pw.date_of_creation BETWEEN vi_start_date AND vi_end_date
      AND pw.id = pwd.part_work_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- MONTOS META
    OPEN itembybudgets;
    read_loop: LOOP
      FETCH itembybudgets INTO v_itembybudget_id, v_order, v_budget_id, v_bill_of_quantity, v_sector_id, v_working_group_id;
      IF done THEN
        LEAVE read_loop;
      END IF;
    
      SET @i_identify = (SELECT p.id FROM itembywbses ibw, wbsitems wi, phases p WHERE ibw.wbsitem_id = wi.id AND p.code > '0___' AND p.code < '89__' AND wi.phase_id = p.id AND ibw.budget_id = v_budget_id AND ibw.order_budget LIKE v_order GROUP BY p.id);

      IF @i_identify IS NOT NULL THEN
        SELECT @i_identify FROM DUAL;
        -- GENERAL
        SELECT LEFT(s.code, 2), s.code, s.name INTO v_sector_cod_padre, v_sector_cod_hijo, v_sector_cod_hijo_name FROM sectors s WHERE s.id = v_sector_id;
        
        SELECT s.name INTO v_sector_cod_padre_name FROM sectors s WHERE s.code LIKE v_sector_cod_padre LIMIT 1;
        
        SET v_itembybudget_sale_id = (SELECT eoi.sale_item_by_budget_id FROM equivalence_of_items eoi WHERE eoi.target_item_by_budget_id = v_itembybudget_id);
        
        SET v_percentage = (SELECT eoi.percentage FROM equivalence_of_items eoi WHERE eoi.target_item_by_budget_id = v_itembybudget_id);
        -- GENERAL

        BLOCKMO: BEGIN
          DECLARE manoObraInsumos CURSOR FOR
            SELECT SUM( ibi.quantity * ibi.price * (IFNULL(v_bill_of_quantity,0)*(IFNULL(v_percentage,0)/100)) ) as 'parcial', SUM( ibi.quantity * (IFNULL(v_bill_of_quantity,0)*(IFNULL(v_percentage,0)/100)) ) as 'cantidad', ibi.cod_input
            FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
            WHERE ibi.cod_input LIKE  '01%' 
            AND ibi.budget_id = v_budget_id 
            AND ib.budget_id = v_budget_id 
            AND ibi.`order` LIKE CONCAT(v_order, '%') 
            AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' )
            GROUP BY ibi.cod_input;
          DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_mo = TRUE;

            OPEN manoObraInsumos;
              read_loop_mo: LOOP
                FETCH manoObraInsumos INTO v_partial_mo, v_amount_mo, v_cod_input_mo;
                IF insumos_mo THEN
                  LEAVE read_loop_mo;
                END IF;

                SELECT a.name, u.name INTO v_cod_input_mo_name, v_cod_input_mo_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_mo AND a.unit_of_measurement_id = u.id;

                SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
                  "`(`article_code`, `article_name`, `article_unit`, `valor_ganado_specific_lvl_1`, `measured_valor_ganado`, `sector_cod_padre`, `sector_cod_padre_nombre`, `sector_cod_hijo`, `sector_cod_hijo_nombre`, `type`, `working_group_id`, `insertion_date`)
                  VALUES ('",v_cod_input_mo, "','", v_cod_input_mo_name, "','", v_cod_input_mo_unit, "','", v_partial_mo, "','", v_amount_mo, "','", v_sector_cod_padre, "','", v_sector_cod_padre_name, "','", v_sector_cod_hijo, "','", v_sector_cod_hijo_name, "','", 'CD', "','", v_working_group_id, "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
                PREPARE stmt FROM @SQL;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;

              END LOOP read_loop_mo;
            CLOSE manoObraInsumos;
        END BLOCKMO;

        BLOCKMATERIAL: BEGIN
          DECLARE materialInsumos CURSOR FOR
            SELECT SUM( ibi.quantity * ibi.price * (IFNULL(v_bill_of_quantity,0)*(IFNULL(v_percentage,0)/100)) ) as 'parcial', SUM( ibi.quantity * (IFNULL(v_bill_of_quantity,0)*(IFNULL(v_percentage,0)/100)) ) as 'cantidad', ibi.cod_input
            FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
            WHERE ibi.cod_input LIKE  '02%' 
            AND ibi.budget_id = v_budget_id 
            AND ib.budget_id = v_budget_id 
            AND ibi.`order` LIKE CONCAT(v_order, '%') 
            AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' )
            GROUP BY ibi.cod_input;
          DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_material = TRUE;

          OPEN materialInsumos;
            read_loop_material: LOOP
              FETCH materialInsumos INTO v_partial_material, v_amount_material, v_cod_input_material;
              IF insumos_material THEN
                LEAVE read_loop_material;
              END IF;

              SELECT a.name, u.name INTO v_cod_input_material_name, v_cod_input_material_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_material AND a.unit_of_measurement_id = u.id;

              SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
                "`(`article_code`, `article_name`, `article_unit`, `valor_ganado_specific_lvl_1`, `measured_valor_ganado`, `sector_cod_padre`, `sector_cod_padre_nombre`, `sector_cod_hijo`, `sector_cod_hijo_nombre`, `type`, `working_group_id`, `insertion_date`)
                VALUES ('",v_cod_input_material, "','", v_cod_input_material_name, "','", v_cod_input_material_unit, "','", v_partial_material, "','", v_amount_material, "','", v_sector_cod_padre, "','", v_sector_cod_padre_name, "','", v_sector_cod_hijo, "','", v_sector_cod_hijo_name, "','", 'CD', "','", v_working_group_id, "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
              PREPARE stmt FROM @SQL;
              EXECUTE stmt;
              DEALLOCATE PREPARE stmt;

            END LOOP read_loop_material;
          CLOSE materialInsumos;
        END BLOCKMATERIAL;

        BLOCKEQUIPMENT: BEGIN
          DECLARE equiposInsumos CURSOR FOR
            SELECT SUM( ibi.quantity * ibi.price * (IFNULL(v_bill_of_quantity,0)*(IFNULL(v_percentage,0)/100)) ) as 'parcial', SUM( ibi.quantity * (IFNULL(v_bill_of_quantity,0)*(IFNULL(v_percentage,0)/100)) ) as 'cantidad', ibi.cod_input
            FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
            WHERE ibi.cod_input LIKE  '03%' 
            AND ibi.budget_id = v_budget_id 
            AND ib.budget_id = v_budget_id 
            AND ibi.`order` LIKE CONCAT(v_order, '%') 
            AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' );
          DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_equipment = TRUE;

            OPEN equiposInsumos;
              read_loop_equipment: LOOP
                FETCH equiposInsumos INTO v_partial_equipment, v_amount_equipment, v_cod_input_equipment;
                IF insumos_equipment THEN
                  LEAVE read_loop_equipment;
                END IF;

                SELECT a.name, u.name INTO v_cod_input_equipment_name, v_cod_input_equipment_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_equipment AND a.unit_of_measurement_id = u.id;

                SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
                  "`(`article_code`, `article_name`, `article_unit`, `valor_ganado_specific_lvl_1`, `measured_valor_ganado`, `sector_cod_padre`, `sector_cod_padre_nombre`, `sector_cod_hijo`, `sector_cod_hijo_nombre`, `type`, `working_group_id`, `insertion_date`)
                  VALUES ('",v_cod_input_equipment, "','", v_cod_input_equipment_name, "','", v_cod_input_equipment_unit, "','", v_partial_equipment, "','", v_amount_equipment, "','", v_sector_cod_padre, "','", v_sector_cod_padre_name, "','", v_sector_cod_hijo, "','", v_sector_cod_hijo_name, "','", 'CD', "','", v_working_group_id, "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
                PREPARE stmt FROM @SQL;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;

              END LOOP read_loop_equipment;
            CLOSE equiposInsumos;
        END BLOCKEQUIPMENT;

        BLOCKSUBCONTRACT: BEGIN
          DECLARE subcontratosInsumos CURSOR FOR
            SELECT SUM( ibi.quantity * ibi.price * (IFNULL(v_bill_of_quantity,0)*(IFNULL(v_percentage,0)/100)) ) as 'parcial', SUM( ibi.quantity * (IFNULL(v_bill_of_quantity,0)*(IFNULL(v_percentage,0)/100)) ) as 'cantidad', ibi.cod_input
            FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
            WHERE ibi.cod_input LIKE  '04%' 
            AND ibi.budget_id = v_budget_id 
            AND ib.budget_id = v_budget_id 
            AND ibi.`order` LIKE CONCAT(v_order, '%') 
            AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' )
            GROUP BY ibi.cod_input;
          DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_subcontract = TRUE;

          OPEN subcontratosInsumos;
            read_loop_subcontracts: LOOP
              FETCH subcontratosInsumos INTO v_partial_subcontract, v_amount_subcontract, v_cod_input_subcontract;
              IF insumos_subcontract THEN
                LEAVE read_loop_subcontracts;
              END IF;

              SELECT a.name, u.name INTO v_cod_input_subcontract_name, v_cod_input_subcontract_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_subcontract AND a.unit_of_measurement_id = u.id;

              SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
                "`(`article_code`, `article_name`, `article_unit`, `valor_ganado_specific_lvl_1`, `measured_valor_ganado`, `sector_cod_padre`, `sector_cod_padre_nombre`, `sector_cod_hijo`, `sector_cod_hijo_nombre`, `type`, `working_group_id`, `insertion_date`)
                VALUES ('",v_cod_input_subcontract, "','", v_cod_input_subcontract_name, "','", v_cod_input_subcontract_unit, "','", v_partial_subcontract, "','", v_amount_subcontract, "','", v_sector_cod_padre, "','", v_sector_cod_padre_name, "','", v_sector_cod_hijo, "','", v_sector_cod_hijo_name, "','", 'CD', "','", v_working_group_id, "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
              PREPARE stmt FROM @SQL;
              EXECUTE stmt;
              DEALLOCATE PREPARE stmt;

            END LOOP read_loop_subcontracts;
          CLOSE subcontratosInsumos;
        END BLOCKSUBCONTRACT;

        BLOCKSERVICE: BEGIN
          DECLARE servicioInsumos CURSOR FOR
            SELECT SUM( ibi.quantity * ibi.price * (IFNULL(v_bill_of_quantity,0)*(IFNULL(v_percentage,0)/100)) ) as 'parcial', SUM( ibi.quantity * (IFNULL(v_bill_of_quantity,0)*(IFNULL(v_percentage,0)/100)) ) as 'cantidad', ibi.cod_input
            FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
            WHERE ibi.cod_input LIKE  '05%' 
            AND ibi.budget_id = v_budget_id 
            AND ib.budget_id = v_budget_id 
            AND ibi.`order` LIKE CONCAT(v_order, '%') 
            AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' )
            GROUP BY ibi.cod_input;
          DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_service = TRUE;

          OPEN servicioInsumos;
            read_loop_service: LOOP
              FETCH servicioInsumos INTO v_partial_service, v_amount_service, v_cod_input_service;
              IF insumos_service THEN
                LEAVE read_loop_service;
              END IF;

              SELECT a.name, u.name INTO v_cod_input_service_name, v_cod_input_service_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_service AND a.unit_of_measurement_id = u.id;

              SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
                "`(`article_code`, `article_name`, `article_unit`, `valor_ganado_specific_lvl_1`, `measured_valor_ganado`, `sector_cod_padre`, `sector_cod_padre_nombre`, `sector_cod_hijo`, `sector_cod_hijo_nombre`, `type`, `working_group_id`, `insertion_date`)
                VALUES ('",v_cod_input_service, "','", v_cod_input_service_name, "','", v_cod_input_service_unit, "','", v_partial_service, "','", v_amount_service, "','", v_sector_cod_padre, "','", v_sector_cod_padre_name, "','", v_sector_cod_hijo, "','", v_sector_cod_hijo_name, "','", 'CD', "','", v_working_group_id, "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
              PREPARE stmt FROM @SQL;
              EXECUTE stmt;
              DEALLOCATE PREPARE stmt;

            END LOOP read_loop_service;
          CLOSE servicioInsumos;
        END BLOCKSERVICE;

      END IF;

    END LOOP read_loop;
    CLOSE itembybudgets;
  END BLOCKCDVG;

  -- COSTO DIRECTO / PROGRAMADO
  BLOCKCDP: BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE insumos_mo INT DEFAULT FALSE;
    DECLARE insumos_material INT DEFAULT FALSE;
    DECLARE insumos_equipment INT DEFAULT FALSE;
    DECLARE insumos_subcontract INT DEFAULT FALSE;
    DECLARE insumos_service INT DEFAULT FALSE;

    DECLARE v_phase_cod_padre CHAR(6);
    DECLARE v_phase_cod_padre_name CHAR(200);

    DECLARE v_phase_cod_hijo CHAR(6);
    DECLARE v_phase_cod_hijo_name CHAR(200);

    DECLARE v_partial_mo FLOAT(10,4);
    DECLARE v_amount_mo FLOAT(10,4);
    DECLARE v_cod_input_mo CHAR(20);
    DECLARE v_cod_input_mo_name CHAR(20);
    DECLARE v_cod_input_mo_unit CHAR(20);

    DECLARE v_partial_material FLOAT(10,4);
    DECLARE v_amount_material FLOAT(10,4);
    DECLARE v_cod_input_material CHAR(20);
    DECLARE v_cod_input_material_name CHAR(20);
    DECLARE v_cod_input_material_unit CHAR(20);

    DECLARE v_partial_equipment FLOAT(10,4);
    DECLARE v_amount_equipment FLOAT(10,4);
    DECLARE v_cod_input_equipment CHAR(20);
    DECLARE v_cod_input_equipment_name CHAR(20);
    DECLARE v_cod_input_equipment_unit CHAR(20);

    DECLARE v_partial_subcontract FLOAT(10,4);
    DECLARE v_amount_subcontract FLOAT(10,4);
    DECLARE v_cod_input_subcontract CHAR(20);
    DECLARE v_cod_input_subcontract_name CHAR(20);
    DECLARE v_cod_input_subcontract_unit CHAR(20);

    DECLARE v_partial_service FLOAT(10,4);
    DECLARE v_amount_service FLOAT(10,4);
    DECLARE v_cod_input_service CHAR(20);
    DECLARE v_cod_input_service_name CHAR(20);
    DECLARE v_cod_input_service_unit CHAR(20);

    DECLARE v_order CHAR(120);
    DECLARE v_measured FLOAT(10,2);
    DECLARE v_budget_id INT;

    DECLARE distributions CURSOR FOR -- ESTO SACA DATOS CON ibb.id REPETIDOS
    SELECT d.code as 'budgetCode', di.value as 'measured', d.budget_id 'budgetId' 
    FROM distributions d, distribution_items di 
    WHERE di.distribution_id = d.id 
    AND di.month BETWEEN vi_start_date AND vi_end_date -- Dato de Entrada
    AND d.cost_center_id = vi_cost_center_id -- Dato de Entrada
    AND di.value IS NOT NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN distributions;
    read_loop: LOOP
      FETCH distributions INTO v_order, v_measured, v_budget_id;
      IF done THEN
        LEAVE read_loop;
      END IF;

      BLOCKMO: BEGIN
        DECLARE manoObraInsumos CURSOR FOR
          SELECT SUM( ibi.quantity * ibi.price * IFNULL(ib.measured,0) ) as 'parcial', SUM( ibi.quantity * IFNULL(ib.measured,0) ) as 'cantidad',ibi.cod_input 
          FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
          WHERE ibi.cod_input LIKE  '01%' 
          AND ibi.budget_id = v_budget_id 
          AND ib.budget_id = v_budget_id 
          AND ibi.`order` LIKE CONCAT(v_order, '%') 
          AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' )
          GROUP BY ibi.cod_input;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_mo = TRUE;

          OPEN manoObraInsumos;
            read_loop_mo: LOOP
              FETCH manoObraInsumos INTO v_partial_mo, v_amount_mo, v_cod_input_mo;
              IF insumos_mo THEN
                LEAVE read_loop_mo;
              END IF;

              SELECT a.name, u.name INTO v_cod_input_mo_name, v_cod_input_mo_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_mo AND a.unit_of_measurement_id = u.id;

              SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
                "`(`article_code`, `article_name`, `article_unit`, `programado_specific_lvl1`, `measured_programado`, `fase_cod_padre`, `fase_cod_padre_nombre`, `fase_cod_hijo`, `fase_cod_hijo_nombre`, `type`, `insertion_date`)
                VALUES ('",v_cod_input_mo, "','", v_cod_input_mo_name, "','", v_cod_input_mo_unit, "','", v_partial_mo, "','", v_amount_mo, "','", IFNULL(v_phase_cod_padre, ''), "','", IFNULL(v_phase_cod_padre_name, ''), "','", IFNULL(v_phase_cod_hijo, ''), "','", IFNULL(v_phase_cod_hijo_name, ''), "','", 'CD', "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
              PREPARE stmt FROM @SQL;
              EXECUTE stmt;
              DEALLOCATE PREPARE stmt;

            END LOOP read_loop_mo;
          CLOSE manoObraInsumos;
      END BLOCKMO;

      BLOCKMATERIAL: BEGIN
        DECLARE materialInsumos CURSOR FOR
          SELECT SUM( ibi.quantity * ibi.price * IFNULL(ib.measured,0) ) as 'parcial', SUM( ibi.quantity * IFNULL(ib.measured,0) ) as 'cantidad',ibi.cod_input 
          FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
          WHERE ibi.cod_input LIKE  '02%' 
          AND ibi.budget_id = v_budget_id 
          AND ib.budget_id = v_budget_id 
          AND ibi.`order` LIKE CONCAT(v_order, '%') 
          AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' )
          GROUP BY ibi.cod_input;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_material = TRUE;

        OPEN materialInsumos;
          read_loop_material: LOOP
            FETCH materialInsumos INTO v_partial_material, v_amount_material, v_cod_input_material;
            IF insumos_material THEN
              LEAVE read_loop_material;
            END IF;

            SELECT a.name, u.name INTO v_cod_input_material_name, v_cod_input_material_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_material AND a.unit_of_measurement_id = u.id;

            SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
              "`(`article_code`, `article_name`, `article_unit`, `programado_specific_lvl1`, `measured_programado`, `fase_cod_padre`, `fase_cod_padre_nombre`, `fase_cod_hijo`, `fase_cod_hijo_nombre`, `type`, `insertion_date`)
              VALUES ('",v_cod_input_material, "','", v_cod_input_material_name, "','", v_cod_input_material_unit, "','", v_partial_material, "','", v_amount_material, "','", IFNULL(v_phase_cod_padre, ''), "','", IFNULL(v_phase_cod_padre_name, ''), "','", IFNULL(v_phase_cod_hijo, ''), "','", IFNULL(v_phase_cod_hijo_name, ''), "','", 'CD', "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
            PREPARE stmt FROM @SQL;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

          END LOOP read_loop_material;
        CLOSE materialInsumos;
      END BLOCKMATERIAL;

      BLOCKEQUIPMENT: BEGIN
        DECLARE equiposInsumos CURSOR FOR
          SELECT SUM( ibi.quantity * ibi.price * IFNULL(ib.measured,0) ) as 'parcial', SUM( ibi.quantity * IFNULL(ib.measured,0) ) as 'cantidad',ibi.cod_input 
          FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
          WHERE ibi.cod_input LIKE  '03%' 
          AND ibi.budget_id = v_budget_id 
          AND ib.budget_id = v_budget_id 
          AND ibi.`order` LIKE CONCAT(v_order, '%') 
          AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' )
          GROUP BY ibi.cod_input;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_equipment = TRUE;

          OPEN equiposInsumos;
            read_loop_equipment: LOOP
              FETCH equiposInsumos INTO v_partial_equipment, v_amount_equipment, v_cod_input_equipment;
              IF insumos_equipment THEN
                LEAVE read_loop_equipment;
              END IF;

              SELECT a.name, u.name INTO v_cod_input_equipment_name, v_cod_input_equipment_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_equipment AND a.unit_of_measurement_id = u.id;

              SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
                "`(`article_code`, `article_name`, `article_unit`, `programado_specific_lvl1`, `measured_programado`, `fase_cod_padre`, `fase_cod_padre_nombre`, `fase_cod_hijo`, `fase_cod_hijo_nombre`, `type`, `insertion_date`)
                VALUES ('",v_cod_input_equipment, "','", v_cod_input_equipment_name, "','", v_cod_input_equipment_unit, "','", v_partial_equipment, "','", v_amount_equipment, "','", IFNULL(v_phase_cod_padre, ''), "','", IFNULL(v_phase_cod_padre_name, ''), "','", IFNULL(v_phase_cod_hijo, ''), "','", IFNULL(v_phase_cod_hijo_name, ''), "','", 'CD', "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
              PREPARE stmt FROM @SQL;
              EXECUTE stmt;
              DEALLOCATE PREPARE stmt;

            END LOOP read_loop_equipment;
          CLOSE equiposInsumos;
      END BLOCKEQUIPMENT;

      BLOCKSUBCONTRACT: BEGIN
        DECLARE subcontratosInsumos CURSOR FOR
          SELECT SUM( ibi.quantity * ibi.price * IFNULL(ib.measured,0) ) as 'parcial', SUM( ibi.quantity * IFNULL(ib.measured,0) ) as 'cantidad',ibi.cod_input 
          FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
          WHERE ibi.cod_input LIKE  '04%' 
          AND ibi.budget_id = v_budget_id 
          AND ib.budget_id = v_budget_id 
          AND ibi.`order` LIKE CONCAT(v_order, '%') 
          AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' )
          GROUP BY ibi.cod_input;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_subcontract = TRUE;

        OPEN subcontratosInsumos;
          read_loop_subcontracts: LOOP
            FETCH subcontratosInsumos INTO v_partial_subcontract, v_amount_subcontract, v_cod_input_subcontract;
            IF insumos_subcontract THEN
              LEAVE read_loop_subcontracts;
            END IF;

            SELECT a.name, u.name INTO v_cod_input_subcontract_name, v_cod_input_subcontract_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_subcontract AND a.unit_of_measurement_id = u.id;

            SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
              "`(`article_code`, `article_name`, `article_unit`, `programado_specific_lvl1`, `measured_programado`, `fase_cod_padre`, `fase_cod_padre_nombre`, `fase_cod_hijo`, `fase_cod_hijo_nombre`, `type`, `insertion_date`)
              VALUES ('",v_cod_input_subcontract, "','", v_cod_input_subcontract_name, "','", v_cod_input_subcontract_unit, "','", v_partial_subcontract, "','", v_amount_subcontract, "','", IFNULL(v_phase_cod_padre, ''), "','", IFNULL(v_phase_cod_padre_name, ''), "','", IFNULL(v_phase_cod_hijo, ''), "','", IFNULL(v_phase_cod_hijo_name, ''), "','", 'CD', "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
            PREPARE stmt FROM @SQL;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;

          END LOOP read_loop_subcontracts;
        CLOSE subcontratosInsumos;
      END BLOCKSUBCONTRACT;

      BLOCKSERVICE: BEGIN
        DECLARE servicioInsumos CURSOR FOR
          SELECT SUM( ibi.quantity * ibi.price * IFNULL(ib.measured,0) ) as 'parcial', SUM( ibi.quantity * IFNULL(ib.measured,0) ) as 'cantidad',ibi.cod_input 
          FROM inputbybudgetanditems AS ibi, itembybudgets AS ib 
          WHERE ibi.cod_input LIKE  '05%' 
          AND ibi.budget_id = v_budget_id 
          AND ib.budget_id = v_budget_id 
          AND ibi.`order` LIKE CONCAT(v_order, '%') 
          AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' )
          GROUP BY ibi.cod_input;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET insumos_service = TRUE;

        OPEN servicioInsumos;
          read_loop_service: LOOP
            FETCH servicioInsumos INTO v_partial_service, v_amount_service, v_cod_input_service;
            IF insumos_service THEN
              LEAVE read_loop_service;
            END IF;

            SELECT a.name, u.name INTO v_cod_input_service_name, v_cod_input_service_unit FROM articles a, unit_of_measurements u WHERE a.code LIKE v_cod_input_service AND a.unit_of_measurement_id = u.id;

            SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
                "`(`article_code`, `article_name`, `article_unit`, `programado_specific_lvl1`, `measured_programado`, `fase_cod_padre`, `fase_cod_padre_nombre`, `fase_cod_hijo`, `fase_cod_hijo_nombre`, `type`, `insertion_date`)
                VALUES ('",v_cod_input_service, "','", v_cod_input_service_name, "','", v_cod_input_service_unit, "','", v_partial_service, "','", v_amount_service, "','", IFNULL(v_phase_cod_padre, ''), "','", IFNULL(v_phase_cod_padre_name, ''), "','", IFNULL(v_phase_cod_hijo, ''), "','", IFNULL(v_phase_cod_hijo_name, ''), "','", 'CD', "','", DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"');");
              PREPARE stmt FROM @SQL;
              EXECUTE stmt;
              DEALLOCATE PREPARE stmt;

          END LOOP read_loop_service;
        CLOSE servicioInsumos;
      END BLOCKSERVICE;

    END LOOP read_loop;
    CLOSE distributions;

  END BLOCKCDP;

  -- COSTO DIRECTO / COSTO REAL
  BLOCKCDCR: BEGIN
    DECLARE done INT DEFAULT FALSE;

    DECLARE real_cost_hand_work FLOAT(10,2);
    DECLARE real_cost_materials FLOAT(10,2);
    DECLARE real_cost_equipment FLOAT(10,2);
    DECLARE real_cost_subcontract FLOAT(10,2);
    DECLARE real_cost_service FLOAT(10,2);

    DECLARE v_article_code TEXT;
    DECLARE v_article_name TEXT;
    DECLARE v_article_unit TEXT;
    DECLARE v_phase_code_padre TEXT;
    DECLARE v_phase_code_hijo TEXT;
    DECLARE v_sector_code_padre TEXT;
    DECLARE v_sector_code_hijo TEXT;
    DECLARE v_working_group INTEGER;

    DECLARE v_quantity FLOAT(10,2);
    DECLARE v_amount FLOAT(10,2);
    DECLARE v_type_article TEXT;
    DECLARE v_order CHAR(120);

    -- STOCK OUTPUTS
    BLOCK3: BEGIN
      DECLARE done3 INT DEFAULT FALSE;
      DECLARE stock_outputs_articles CURSOR FOR 
        SELECT art.code, art.name, unit.symbol, CAST(p.code AS CHAR), CAST( se.code AS CHAR ) , (SUM(pod.unit_price_igv-IFNULL(pod.discount_after,0))/SUM(dod.amount)*stock_output.amount), stock_output.amount
        FROM articles art, purchase_orders po, purchase_order_details pod, delivery_order_details dod, phases p, unit_of_measurements unit, sectors se,
             (SELECT art.id AS article_id, SUM( sid.amount ) AS amount
              FROM stock_inputs si, stock_input_details sid, articles art
              WHERE si.input = 0
              AND si.cost_center_id = vi_cost_center_id
              AND si.status =  'A'
              AND sid.stock_input_id = si.id
              AND si.issue_date BETWEEN vi_start_date AND vi_end_date
              AND sid.article_id = art.id
              GROUP BY art.id) AS stock_output
        WHERE dod.article_id = stock_output.article_id
        AND art.id = dod.article_id
        AND dod.phase_id = p.id
        AND dod.sector_id = se.id
        AND p.code > '0___' AND p.code < '89__'
        AND pod.delivery_order_detail_id = dod.id
        AND po.id = pod.purchase_order_id
        AND po.cost_center_id = vi_cost_center_id
        AND art.unit_of_measurement_id = unit.id
        GROUP BY art.id;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done3 = TRUE;

      OPEN stock_outputs_articles;
      read_loop3: LOOP
        FETCH stock_outputs_articles INTO v_article_code, v_article_name, v_article_unit, v_phase_code_hijo, v_sector_code_hijo, v_amount, v_quantity;
        IF done3 THEN
          LEAVE read_loop3;
        END IF;

        SET @phase_padre = (SELECT name FROM phases WHERE code = LEFT(v_phase_code_hijo,2));
        SET @phase_nombre = (SELECT name FROM phases WHERE code = v_phase_code_hijo);
        SET @sector_padre = (SELECT name FROM sectors WHERE code = LEFT(v_sector_code_hijo,2) AND cost_center_id = vi_cost_center_id);
        SET @sector_nombre = (SELECT name FROM sectors WHERE code = v_sector_code_hijo AND cost_center_id = vi_cost_center_id);

        SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
          "`(`article_code`,`article_name`,`article_unit`,`real_specific_lvl_1`,
            `fase_cod_hijo`,`fase_cod_hijo_nombre`,`fase_cod_padre`,`fase_cod_padre_nombre`,
            `sector_cod_hijo`,`sector_cod_hijo_nombre`,`sector_cod_padre`,`sector_cod_padre_nombre`,
             `measured_real`,`insertion_date`, `type`)
            VALUES (
              '",v_article_code, "','", v_article_name, "','", v_article_unit, "',", v_amount, ",'", 
              v_phase_code_hijo,"','",@phase_nombre,"','",LEFT(v_phase_code_hijo,2),"','",@phase_padre,"','",
              v_sector_code_hijo,"','",@sector_nombre,"','",LEFT(v_sector_code_hijo,2),"','",@sector_padre,"',",
              v_quantity,", '",DATE_ADD(vi_start_date, INTERVAL -1 DAY),"','GG');");
        PREPARE stmt FROM @SQL;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
      END LOOP;
      CLOSE stock_outputs_articles;
    END BLOCK3;
    -- STOCK OUTPUTS

    -- ORDER OF SERVICE
    BLOCK4: BEGIN
      DECLARE done4 INT DEFAULT FALSE;
      DECLARE order_of_services_articles CURSOR FOR 

        SELECT art.code, art.name, unit.symbol, CAST(p.code AS CHAR), CAST( se.code AS CHAR ) , SUM(osd.unit_price_igv - IFNULL(osd.discount_after,0)), osd.amount
        FROM order_of_service_details osd, phases p, order_of_services os, articles art, unit_of_measurements unit, sectors se 
        WHERE osd.phase_id = p.id
        AND osd.sector_id = se.id
        AND os.id = osd.order_of_service_id
        AND os.date_of_issue BETWEEN vi_start_date AND vi_end_date
        AND os.cost_center_id = vi_cost_center_id
        AND osd.article_id = art.id
        AND p.code > '0___' AND p.code < '89__'
        AND os.state =  'approved'
        AND art.unit_of_measurement_id = unit.id
        GROUP BY art.id;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done4 = TRUE;
      OPEN order_of_services_articles;
      read_loop4: LOOP
        FETCH order_of_services_articles INTO v_article_code, v_article_name, v_article_unit, v_phase_code_hijo, v_sector_code_hijo, v_amount, v_quantity;
        IF done4 THEN
          LEAVE read_loop4;
        END IF;

        SET @phase_padre = (SELECT name FROM phases WHERE code = LEFT(v_phase_code_hijo,2));
        SET @phase_nombre = (SELECT name FROM phases WHERE code = v_phase_code_hijo);
        SET @sector_padre = (SELECT name FROM sectors WHERE code = LEFT(v_sector_code_hijo,2) AND cost_center_id = vi_cost_center_id);
        SET @sector_nombre = (SELECT name FROM sectors WHERE code = v_sector_code_hijo AND cost_center_id = vi_cost_center_id);


        SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
          "`(`article_code`,`article_name`,`article_unit`,`real_specific_lvl_1`,
            `fase_cod_hijo`,`fase_cod_hijo_nombre`,`fase_cod_padre`,`fase_cod_padre_nombre`,
            `sector_cod_hijo`,`sector_cod_hijo_nombre`,`sector_cod_padre`,`sector_cod_padre_nombre`,
             `measured_real`,`insertion_date`, `type`)
            VALUES (
              '",v_article_code, "','", v_article_name, "','", v_article_unit, "',", v_amount, ",'", 
              v_phase_code_hijo,"','",@phase_nombre,"','",LEFT(v_phase_code_hijo,2),"','",@phase_padre,"','",
              v_sector_code_hijo,"','",@sector_nombre,"','",LEFT(v_sector_code_hijo,2),"','",@sector_padre,"',",
              v_quantity,", '",DATE_ADD(vi_start_date, INTERVAL -1 DAY),"', 'GG');");

        PREPARE stmt FROM @SQL;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
      END LOOP;
      CLOSE order_of_services_articles;
    END BLOCK4;
    -- ORDER OF SERVICE

    -- PAYROLLS
    BLOCK5: BEGIN
      DECLARE done5 INT DEFAULT FALSE;
      DECLARE done5pw INT DEFAULT FALSE;   
      DECLARE v_worker INT;
      DECLARE v_total_h FLOAT(10,2);
      DECLARE v_neto FLOAT(10,2);
      DECLARE v_date_begin DATE;
      DECLARE v_date_end DATE;

      -- part_people
      DECLARE payroll CURSOR FOR 
        SELECT ppd.worker_id, SUM(ppd.total_hours), payslips_worker.Neto, payslips_worker.date_begin, payslips_worker.date_end 
        FROM part_people pp, part_person_details ppd, phases p,
          (SELECT p.worker_id AS worker_id, p.date_begin AS date_begin, p.date_end AS date_end, IFNULL(SUM(CAST(REPLACE( SUBSTRING_INDEX( aport_and_amounts, '","', 1 ) , '{"neto":"', '' ) as DECIMAL(9,2))),0) AS Neto
           FROM payslips p
           WHERE p.cost_center_id = vi_cost_center_id
           AND p.date_begin BETWEEN vi_start_date AND vi_end_date
           GROUP BY p.worker_id) AS payslips_worker
        WHERE ppd.part_person_id = pp.id
        AND payslips_worker.worker_id = ppd.worker_id
        AND pp.blockweekly = 1
        AND pp.cost_center_id = vi_cost_center_id
        AND ppd.phase_id = p.id
        AND pp.date_of_creation BETWEEN payslips_worker.date_begin AND payslips_worker.date_end
        GROUP BY ppd.worker_id;
      -- part_people

      -- part_workers
      DECLARE payrollpw CURSOR FOR 
        SELECT pwd.worker_id, SUM( 8.5 ), payslips_worker.Neto, payslips_worker.date_begin, payslips_worker.date_end 
        FROM part_workers pw, part_worker_details pwd,
          (SELECT p.worker_id AS worker_id, p.date_begin AS date_begin, p.date_end AS date_end, IFNULL(SUM(CAST(REPLACE( SUBSTRING_INDEX( aport_and_amounts, '","', 1 ) , '{"neto":"', '' ) as DECIMAL(9,2))),0) AS Neto
           FROM payslips p
           WHERE p.cost_center_id = vi_cost_center_id
           AND p.date_begin BETWEEN vi_start_date AND vi_end_date
           GROUP BY p.worker_id) AS payslips_worker
        WHERE pw.cost_center_id = vi_cost_center_id
        AND pw.id = pwd.part_worker_id
        AND payslips_worker.worker_id = pwd.worker_id
        AND pwd.assistance =  'si'
        AND pw.blockweekly = 1
        AND pw.date_of_creation BETWEEN payslips_worker.date_begin AND payslips_worker.date_end
        GROUP BY pwd.worker_id;
      -- part_workers
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done5 = TRUE;

      -- part_people
      OPEN payroll;
      read_loop5: LOOP
        FETCH payroll INTO v_worker, v_total_h, v_neto, v_date_begin, v_date_end;
        IF done5 THEN
          LEAVE read_loop5;
        END IF;
        BLOCKArtPayrollPP: BEGIN
          DECLARE done5ppart INT DEFAULT FALSE;
          DECLARE v_pay FLOAT (10,2);
          
          DECLARE articles_payroll CURSOR FOR
            SELECT art.code, art.name, unit.symbol, CAST( se.code AS CHAR ), CAST(p.code AS CHAR), SUM( ppd.total_hours )
            FROM part_people pp, part_person_details ppd, phases p, articles art, workers w, worker_contracts wc, unit_of_measurements unit, sectors s
            WHERE ppd.part_person_id = pp.id
            AND ppd.worker_id = v_worker
            AND ppd.phase_id = p.id
            AND ppd.sector_id = se.id
            AND pp.blockweekly = 1
            AND pp.cost_center_id =1
            AND ppd.phase_id = p.id
            AND pp.date_of_creation BETWEEN vi_start_date AND vi_end_date
            AND p.code > '0___' AND p.code < '89__'
            AND ppd.worker_id = w.id
            AND wc.worker_id = w.id
            AND wc.status = 1
            AND wc.article_id = art.id
            AND art.unit_of_measurement_id = unit.id
            GROUP BY ppd.worker_id;
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done5ppart = TRUE;       
          OPEN articles_payroll;
          read_loop5pwartp: LOOP
            FETCH articles_payroll INTO v_article_code, v_article_name, v_article_unit, v_sector_code_hijo, v_phase_code_hijo, v_pay;
            IF done5ppart THEN
              LEAVE read_loop5pwartp;
            END IF;
            SET @phase_padre = (SELECT name FROM phases WHERE code = LEFT(v_phase_code_hijo,2));
            SET @phase_nombre = (SELECT name FROM phases WHERE code = v_phase_code_hijo);
            SET @sector_padre = (SELECT name FROM sectors WHERE code = LEFT(v_sector_code_hijo,2) AND cost_center_id = vi_cost_center_id);
            SET @sector_nombre = (SELECT name FROM sectors WHERE code = v_sector_code_hijo AND cost_center_id = vi_cost_center_id);

            SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
              "`(`article_code`,`article_name`,`article_unit`,`real_specific_lvl_1`,
                `fase_cod_hijo`,`fase_cod_hijo_nombre`,`fase_cod_padre`,`fase_cod_padre_nombre`,
                `sector_cod_hijo`,`sector_cod_hijo_nombre`,`sector_cod_padre`,`sector_cod_padre_nombre`,
                 `measured_real`,`insertion_date`,`type`)
                VALUES (
                  '",v_article_code, "','", v_article_name, "','", v_article_unit, "',", v_amount, ",'", 
                  v_phase_code_hijo,"','",@phase_nombre,"','",LEFT(v_phase_code_hijo,2),"','",@phase_padre,"','",
                  v_sector_code_hijo,"','",@sector_nombre,"','",LEFT(v_sector_code_hijo,2),"','",@sector_padre,"',",
                  v_quantity,", '",DATE_ADD(vi_start_date, INTERVAL -1 DAY),"','GG');");

            PREPARE stmt FROM @SQL;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
          END LOOP read_loop5pwartp;
          CLOSE articles_payroll; 
        END BLOCKArtPayrollPP;
      END LOOP;
      CLOSE payroll; 
      -- part_people      
      SET done5 = 0;
      -- part_workers
      OPEN payrollpw;
      read_loop5pw: LOOP
        FETCH payrollpw INTO v_worker, v_total_h, v_neto, v_date_begin, v_date_end;
        IF done5 THEN
          LEAVE read_loop5pw;
        END IF;

        BLOCKArtPayrollPPW: BEGIN
          DECLARE done5ppartw INT DEFAULT FALSE;
          DECLARE v_pay FLOAT (10,2);
          
          DECLARE articles_payrollw CURSOR FOR
            SELECT art.code, art.name, unit.symbol, CAST( se.code AS CHAR ) , CAST(ph.code AS CHAR), SUM(8.5)
            FROM part_workers pw, part_worker_details pwd, phases p, articles art, workers w, worker_contracts wc, unit_of_measurements unit, sectors se
            WHERE pwd.part_worker_id = pp.id AND pwd.worker_id = v_worker 
            AND pw.blockweekly = 1
            AND pwd.sector_id = se.id
            AND pwd.phase_id = ph.id
            AND pw.cost_center_id = vi_cost_center_id 
            AND pwd.phase_id = p.id
            AND pw.date_of_creation BETWEEN v_date_begin AND v_date_end 
            AND p.code > '0___' AND p.code < '89__'
            AND pwd.worker_id = w.id
            AND wc.worker_id = w.id
            AND wc.status = 1
            AND wc.article_id = art.id
            AND art.unit_of_measurement_id = unit.id
            GROUP BY pwd.worker_id;    

            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done5ppartw = TRUE;       
          OPEN articles_payrollw;
          read_loop5pwart: LOOP
            FETCH articles_payrollw INTO v_article_code, v_article_name, v_article_unit, v_sector_code_hijo, v_phase_code_hijo, v_pay;
            IF done5ppartw THEN
              LEAVE read_loop5pwart;
            END IF;
            SET @phase_padre = (SELECT name FROM phases WHERE code = LEFT(v_phase_code_hijo,2));
            SET @phase_nombre = (SELECT name FROM phases WHERE code = v_phase_code_hijo);
            SET @sector_padre = (SELECT name FROM sectors WHERE code = LEFT(v_sector_code_hijo,2) AND cost_center_id = vi_cost_center_id);
            SET @sector_nombre = (SELECT name FROM sectors WHERE code = v_sector_code_hijo AND cost_center_id = vi_cost_center_id);

            SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(vi_start_date,'%m%Y'),
              "`(`article_code`,`article_name`,`article_unit`,`real_specific_lvl_1`,
                `fase_cod_hijo`,`fase_cod_hijo_nombre`,`fase_cod_padre`,`fase_cod_padre_nombre`,
                `sector_cod_hijo`,`sector_cod_hijo_nombre`,`sector_cod_padre`,`sector_cod_padre_nombre`,
                 `measured_real`,`insertion_date`, `type`)
                VALUES (
                  '",v_article_code, "','", v_article_name, "','", v_article_unit, "',", v_total_h/v_pay*v_neto, ",'", 
                  v_phase_code_hijo,"','",@phase_nombre,"','",LEFT(v_phase_code_hijo,2),"','",@phase_padre,"','",
                  v_sector_code_hijo,"','",@sector_nombre,"','",LEFT(v_sector_code_hijo,2),"','",@sector_padre,"',",
                  v_quantity,", '",DATE_ADD(vi_start_date, INTERVAL -1 DAY),"', 'GG');");

            PREPARE stmt FROM @SQL;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
          END LOOP read_loop5pwart;

          CLOSE articles_payrollw; 
        END BLOCKArtPayrollPPW;        
      END LOOP read_loop5pw;
      CLOSE payrollpw;
      -- part_workers
    END BLOCK5;
    -- PAYROLLS

  END BLOCKCDCR;

  -- GASTOS GENERALES META
  BLOCK2: BEGIN
    DECLARE done2 INT DEFAULT FALSE;
    DECLARE articles_gg_meta CURSOR FOR 
      SELECT art.code, art.name, unit.symbol, CAST(ph.code AS CHAR), SUM( ged.parcial ), IFNULL( ged.people, ged.amount)
      FROM general_expense_details ged, general_expenses ge, articles art, unit_of_measurements unit, phases ph
      WHERE ged.general_expense_id = ge.id
      AND ge.cost_center_id = vi_cost_center_id
      AND DATE_FORMAT( ged.created_at,  '%Y-%m-%d' ) BETWEEN vi_start_date AND vi_end_date
      AND ge.code_phase = 90
      AND ge.phase_id = ph.id
      AND ged.article_id = art.id
      AND art.unit_of_measurement_id = unit.id
      GROUP BY (art.code);
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = TRUE;
    OPEN articles_gg_meta;
    read_loop2: LOOP
      FETCH articles_gg_meta INTO v_article_code, v_article_name, v_article_unit, v_phase_code_hijo, v_amount, v_quantity;
      IF done2 THEN
        LEAVE read_loop2;
      END IF;
      SET @phase_padre = (SELECT name FROM phases WHERE code = LEFT(v_phase_code_hijo,2));
      SET @phase_nombre = (SELECT name FROM phases WHERE code = v_phase_code_hijo);
      SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%m%Y'),
        "`(`article_code`,`article_name`,`article_unit`,`meta_specific_lvl_1`,
          `fase_cod_hijo`,`fase_cod_hijo_nombre`,`fase_cod_padre`,`fase_cod_padre_nombre`,
           `measured_meta`,`insertion_date`, `type`)
          VALUES (
            '",v_article_code, "','", v_article_name, "','", v_article_unit, "',", v_amount, ",'",
            v_phase_code_hijo,"','",@phase_nombre,"','",LEFT(v_phase_code_hijo,2),"','",@phase_padre,"',",
            v_quantity,",'",DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"', 'GG');");
      PREPARE stmt FROM @SQL;
      EXECUTE stmt;
      DEALLOCATE PREPARE stmt;             
    END LOOP;
    CLOSE articles_gg_meta;
  END BLOCK2;
  -- GASTOS GENERALES META

  -- GASTOS GENERALES REAL
  -- STOCK OUTPUTS
  BLOCK3: BEGIN
    DECLARE done3 INT DEFAULT FALSE;
    DECLARE stock_outputs_articles CURSOR FOR 
      SELECT art.code, art.name, unit.symbol, CAST(p.code AS CHAR), CAST( se.code AS CHAR ) , (SUM(pod.unit_price_igv-IFNULL(pod.discount_after,0))/SUM(dod.amount)*stock_output.amount), stock_output.amount
      FROM articles art, purchase_orders po, purchase_order_details pod, delivery_order_details dod, phases p, unit_of_measurements unit, sectors se,
           (SELECT art.id AS article_id, SUM( sid.amount ) AS amount
            FROM stock_inputs si, stock_input_details sid, articles art
            WHERE si.input = 0
            AND si.cost_center_id = vi_cost_center_id
            AND si.status =  'A'
            AND sid.stock_input_id = si.id
            AND si.issue_date BETWEEN vi_start_date AND vi_end_date
            AND sid.article_id = art.id
            GROUP BY art.id) AS stock_output
      WHERE dod.article_id = stock_output.article_id
      AND art.id = dod.article_id
      AND dod.phase_id = p.id
      AND dod.sector_id = se.id
      AND p.code LIKE '90__'
      AND pod.delivery_order_detail_id = dod.id
      AND po.id = pod.purchase_order_id
      AND po.cost_center_id = vi_cost_center_id
      AND art.unit_of_measurement_id = unit.id
      GROUP BY art.id;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done3 = TRUE;

    OPEN stock_outputs_articles;
    read_loop3: LOOP
      FETCH stock_outputs_articles INTO v_article_code, v_article_name, v_article_unit, v_phase_code_hijo, v_sector_code_hijo, v_amount, v_quantity;
      IF done3 THEN
        LEAVE read_loop3;
      END IF;

      SET @phase_padre = (SELECT name FROM phases WHERE code = LEFT(v_phase_code_hijo,2));
      SET @phase_nombre = (SELECT name FROM phases WHERE code = v_phase_code_hijo);
      SET @sector_padre = (SELECT name FROM sectors WHERE code = LEFT(v_sector_code_hijo,2) AND cost_center_id = vi_cost_center_id);
      SET @sector_nombre = (SELECT name FROM sectors WHERE code = v_sector_code_hijo AND cost_center_id = vi_cost_center_id);

      SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%m%Y'),
        "`(`article_code`,`article_name`,`article_unit`,`real_specific_lvl_1`,
          `fase_cod_hijo`,`fase_cod_hijo_nombre`,`fase_cod_padre`,`fase_cod_padre_nombre`,
          `sector_cod_hijo`,`sector_cod_hijo_nombre`,`sector_cod_padre`,`sector_cod_padre_nombre`,
           `measured_real`,`insertion_date`, `type`)
          VALUES (
            '",v_article_code, "','", v_article_name, "','", v_article_unit, "',", v_amount, ",'", 
            v_phase_code_hijo,"','",@phase_nombre,"','",LEFT(v_phase_code_hijo,2),"','",@phase_padre,"','",
            v_sector_code_hijo,"','",@sector_nombre,"','",LEFT(v_sector_code_hijo,2),"','",@sector_padre,"',",
            v_quantity,", '",vi_end_date,"','GG');");
      PREPARE stmt FROM @SQL;
      EXECUTE stmt;
      DEALLOCATE PREPARE stmt;
    END LOOP;
    CLOSE stock_outputs_articles;
  END BLOCK3;
  -- STOCK OUTPUTS

  -- ORDER OF SERVICE
  BLOCK4: BEGIN
    DECLARE done4 INT DEFAULT FALSE;
    DECLARE order_of_services_articles CURSOR FOR 

      SELECT art.code, art.name, unit.symbol, CAST(p.code AS CHAR), CAST( se.code AS CHAR ) , SUM(osd.unit_price_igv - IFNULL(osd.discount_after,0)), osd.amount
      FROM order_of_service_details osd, phases p, order_of_services os, articles art, unit_of_measurements unit, sectors se 
      WHERE osd.phase_id = p.id
      AND osd.sector_id = se.id
      AND os.id = osd.order_of_service_id
      AND os.date_of_issue BETWEEN vi_start_date AND vi_end_date
      AND os.cost_center_id = vi_cost_center_id
      AND osd.article_id = art.id
      AND p.code LIKE  '90__'
      AND os.state =  'approved'
      AND art.unit_of_measurement_id = unit.id
      GROUP BY art.id;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done4 = TRUE;
    OPEN order_of_services_articles;
    read_loop4: LOOP
      FETCH order_of_services_articles INTO v_article_code, v_article_name, v_article_unit, v_phase_code_hijo, v_sector_code_hijo, v_amount, v_quantity;
      IF done4 THEN
        LEAVE read_loop4;
      END IF;

      SET @phase_padre = (SELECT name FROM phases WHERE code = LEFT(v_phase_code_hijo,2));
      SET @phase_nombre = (SELECT name FROM phases WHERE code = v_phase_code_hijo);
      SET @sector_padre = (SELECT name FROM sectors WHERE code = LEFT(v_sector_code_hijo,2) AND cost_center_id = vi_cost_center_id);
      SET @sector_nombre = (SELECT name FROM sectors WHERE code = v_sector_code_hijo AND cost_center_id = vi_cost_center_id);


      SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%m%Y'),
        "`(`article_code`,`article_name`,`article_unit`,`real_specific_lvl_1`,
          `fase_cod_hijo`,`fase_cod_hijo_nombre`,`fase_cod_padre`,`fase_cod_padre_nombre`,
          `sector_cod_hijo`,`sector_cod_hijo_nombre`,`sector_cod_padre`,`sector_cod_padre_nombre`,
           `measured_real`,`insertion_date`, `type`)
          VALUES (
            '",v_article_code, "','", v_article_name, "','", v_article_unit, "',", v_amount, ",'", 
            v_phase_code_hijo,"','",@phase_nombre,"','",LEFT(v_phase_code_hijo,2),"','",@phase_padre,"','",
            v_sector_code_hijo,"','",@sector_nombre,"','",LEFT(v_sector_code_hijo,2),"','",@sector_padre,"',",
            v_quantity,", '",vi_end_date,"', 'GG');");

      PREPARE stmt FROM @SQL;
      EXECUTE stmt;
      DEALLOCATE PREPARE stmt;
    END LOOP;
    CLOSE order_of_services_articles;
  END BLOCK4;
  -- ORDER OF SERVICE

  -- PAYROLLS
  BLOCK5: BEGIN
    DECLARE done5 INT DEFAULT FALSE;
    DECLARE done5pw INT DEFAULT FALSE;   
    DECLARE v_worker INT;
    DECLARE v_total_h FLOAT(10,2);
    DECLARE v_neto FLOAT(10,2);
    DECLARE v_date_begin DATE;
    DECLARE v_date_end DATE;

    -- part_people
    DECLARE payroll CURSOR FOR 
      SELECT ppd.worker_id, SUM(ppd.total_hours), payslips_worker.Neto, payslips_worker.date_begin, payslips_worker.date_end 
      FROM part_people pp, part_person_details ppd, phases p,
        (SELECT p.worker_id AS worker_id, p.date_begin AS date_begin, p.date_end AS date_end, IFNULL(SUM(CAST(REPLACE( SUBSTRING_INDEX( aport_and_amounts, '","', 1 ) , '{"neto":"', '' ) as DECIMAL(9,2))),0) AS Neto
         FROM payslips p
         WHERE p.cost_center_id = vi_cost_center_id
         AND p.date_begin BETWEEN vi_start_date AND vi_end_date
         GROUP BY p.worker_id) AS payslips_worker
      WHERE ppd.part_person_id = pp.id
      AND payslips_worker.worker_id = ppd.worker_id
      AND pp.blockweekly = 1
      AND pp.cost_center_id = vi_cost_center_id
      AND ppd.phase_id = p.id
      AND pp.date_of_creation BETWEEN payslips_worker.date_begin AND payslips_worker.date_end
      GROUP BY ppd.worker_id;
    -- part_people

    -- part_workers
    DECLARE payrollpw CURSOR FOR 
      SELECT pwd.worker_id, SUM( 8.5 ), payslips_worker.Neto, payslips_worker.date_begin, payslips_worker.date_end 
      FROM part_workers pw, part_worker_details pwd,
        (SELECT p.worker_id AS worker_id, p.date_begin AS date_begin, p.date_end AS date_end, IFNULL(SUM(CAST(REPLACE( SUBSTRING_INDEX( aport_and_amounts, '","', 1 ) , '{"neto":"', '' ) as DECIMAL(9,2))),0) AS Neto
         FROM payslips p
         WHERE p.cost_center_id = vi_cost_center_id
         AND p.date_begin BETWEEN vi_start_date AND vi_end_date
         GROUP BY p.worker_id) AS payslips_worker
      WHERE pw.cost_center_id = vi_cost_center_id
      AND pw.id = pwd.part_worker_id
      AND payslips_worker.worker_id = pwd.worker_id
      AND pwd.assistance =  'si'
      AND pw.blockweekly = 1
      AND pw.date_of_creation BETWEEN payslips_worker.date_begin AND payslips_worker.date_end
      GROUP BY pwd.worker_id;
    -- part_workers
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done5 = TRUE;

    -- part_people
    OPEN payroll;
    read_loop5: LOOP
      FETCH payroll INTO v_worker, v_total_h, v_neto, v_date_begin, v_date_end;
      IF done5 THEN
        LEAVE read_loop5;
      END IF;
      BLOCKArtPayrollPP: BEGIN
        DECLARE done5ppart INT DEFAULT FALSE;
        DECLARE v_pay FLOAT (10,2);
        
        DECLARE articles_payroll CURSOR FOR
          SELECT art.code, art.name, unit.symbol, CAST( se.code AS CHAR ), CAST(p.code AS CHAR), SUM( ppd.total_hours )
          FROM part_people pp, part_person_details ppd, phases p, articles art, workers w, worker_contracts wc, unit_of_measurements unit, sectors s
          WHERE ppd.part_person_id = pp.id
          AND ppd.worker_id = v_worker
          AND ppd.phase_id = p.id
          AND ppd.sector_id = se.id
          AND pp.blockweekly = 1
          AND pp.cost_center_id =1
          AND ppd.phase_id = p.id
          AND pp.date_of_creation BETWEEN vi_start_date AND vi_end_date
          AND p.code LIKE  '90__'
          AND ppd.worker_id = w.id
          AND wc.worker_id = w.id
          AND wc.status = 1
          AND wc.article_id = art.id
          AND art.unit_of_measurement_id = unit.id
          GROUP BY ppd.worker_id;
          DECLARE CONTINUE HANDLER FOR NOT FOUND SET done5ppart = TRUE;       
        OPEN articles_payroll;
        read_loop5pwartp: LOOP
          FETCH articles_payroll INTO v_article_code, v_article_name, v_article_unit, v_sector_code_hijo, v_phase_code_hijo, v_pay;
          IF done5ppart THEN
            LEAVE read_loop5pwartp;
          END IF;
          SET @phase_padre = (SELECT name FROM phases WHERE code = LEFT(v_phase_code_hijo,2));
          SET @phase_nombre = (SELECT name FROM phases WHERE code = v_phase_code_hijo);
          SET @sector_padre = (SELECT name FROM sectors WHERE code = LEFT(v_sector_code_hijo,2) AND cost_center_id = vi_cost_center_id);
          SET @sector_nombre = (SELECT name FROM sectors WHERE code = v_sector_code_hijo AND cost_center_id = vi_cost_center_id);

          SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%m%Y'),
            "`(`article_code`,`article_name`,`article_unit`,`real_specific_lvl_1`,
              `fase_cod_hijo`,`fase_cod_hijo_nombre`,`fase_cod_padre`,`fase_cod_padre_nombre`,
              `sector_cod_hijo`,`sector_cod_hijo_nombre`,`sector_cod_padre`,`sector_cod_padre_nombre`,
               `measured_real`,`insertion_date`,`type`)
              VALUES (
                '",v_article_code, "','", v_article_name, "','", v_article_unit, "',", v_amount, ",'", 
                v_phase_code_hijo,"','",@phase_nombre,"','",LEFT(v_phase_code_hijo,2),"','",@phase_padre,"','",
                v_sector_code_hijo,"','",@sector_nombre,"','",LEFT(v_sector_code_hijo,2),"','",@sector_padre,"',",
                v_quantity,", '",vi_end_date,"','GG');");

          PREPARE stmt FROM @SQL;
          EXECUTE stmt;
          DEALLOCATE PREPARE stmt;
        END LOOP read_loop5pwartp;
        CLOSE articles_payroll; 
      END BLOCKArtPayrollPP;
    END LOOP;
    CLOSE payroll; 
    -- part_people      
    SET done5 = 0;
    -- part_workers
    OPEN payrollpw;
    read_loop5pw: LOOP
      FETCH payrollpw INTO v_worker, v_total_h, v_neto, v_date_begin, v_date_end;
      IF done5 THEN
        LEAVE read_loop5pw;
      END IF;

      BLOCKArtPayrollPPW: BEGIN
        DECLARE done5ppartw INT DEFAULT FALSE;
        DECLARE v_pay FLOAT (10,2);
        
        DECLARE articles_payrollw CURSOR FOR
          SELECT art.code, art.name, unit.symbol, CAST( se.code AS CHAR ) , CAST(ph.code AS CHAR), SUM(8.5)
          FROM part_workers pw, part_worker_details pwd, phases p, articles art, workers w, worker_contracts wc, unit_of_measurements unit, sectors se
          WHERE pwd.part_worker_id = pp.id AND pwd.worker_id = v_worker 
          AND pw.blockweekly = 1
          AND pwd.sector_id = se.id
          AND pwd.phase_id = ph.id
          AND pw.cost_center_id = vi_cost_center_id 
          AND pwd.phase_id = p.id
          AND pw.date_of_creation BETWEEN v_date_begin AND v_date_end 
          AND p.code LIKE '90__'
          AND pwd.worker_id = w.id
          AND wc.worker_id = w.id
          AND wc.status = 1
          AND wc.article_id = art.id
          AND art.unit_of_measurement_id = unit.id
          GROUP BY pwd.worker_id;    

          DECLARE CONTINUE HANDLER FOR NOT FOUND SET done5ppartw = TRUE;       
        OPEN articles_payrollw;
        read_loop5pwart: LOOP
          FETCH articles_payrollw INTO v_article_code, v_article_name, v_article_unit, v_sector_code_hijo, v_phase_code_hijo, v_pay;
          IF done5ppartw THEN
            LEAVE read_loop5pwart;
          END IF;
          SET @phase_padre = (SELECT name FROM phases WHERE code = LEFT(v_phase_code_hijo,2));
          SET @phase_nombre = (SELECT name FROM phases WHERE code = v_phase_code_hijo);
          SET @sector_padre = (SELECT name FROM sectors WHERE code = LEFT(v_sector_code_hijo,2) AND cost_center_id = vi_cost_center_id);
          SET @sector_nombre = (SELECT name FROM sectors WHERE code = v_sector_code_hijo AND cost_center_id = vi_cost_center_id);

          SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%m%Y'),
            "`(`article_code`,`article_name`,`article_unit`,`real_specific_lvl_1`,
              `fase_cod_hijo`,`fase_cod_hijo_nombre`,`fase_cod_padre`,`fase_cod_padre_nombre`,
              `sector_cod_hijo`,`sector_cod_hijo_nombre`,`sector_cod_padre`,`sector_cod_padre_nombre`,
               `measured_real`,`insertion_date`, `type`)
              VALUES (
                '",v_article_code, "','", v_article_name, "','", v_article_unit, "',", v_total_h/v_pay*v_neto, ",'", 
                v_phase_code_hijo,"','",@phase_nombre,"','",LEFT(v_phase_code_hijo,2),"','",@phase_padre,"','",
                v_sector_code_hijo,"','",@sector_nombre,"','",LEFT(v_sector_code_hijo,2),"','",@sector_padre,"',",
                v_quantity,", '",vi_end_date,"', 'GG');");

          PREPARE stmt FROM @SQL;
          EXECUTE stmt;
          DEALLOCATE PREPARE stmt;
        END LOOP read_loop5pwart;

        CLOSE articles_payrollw; 
      END BLOCKArtPayrollPPW;        
    END LOOP read_loop5pw;
    CLOSE payrollpw;
    -- part_workers
  END BLOCK5;
  -- PAYROLLS
  -- GASTOS GENERALES REAL

  -- GASTOS GENERALES VALORIZADO
  BLOCK6: BEGIN
    DECLARE done6 INT DEFAULT FALSE;
    DECLARE valorizacion CURSOR FOR 
      SELECT im.item_code AS type_article, SUM( i.measured * i.price )*budget.general_expenses -- FALTA CANTIDAD 
      FROM valorizations va, valorizationitems v, itembybudgets i, items im, 
           (SELECT b.id, b.general_expenses
            FROM budgets b
            WHERE b.cost_center_id = vi_cost_center_id
            AND b.type_of_budget = 1
         ) AS budget
      WHERE v.valorization_id = va.id
      AND va.budget_id = budget.id
      AND va.month LIKE CONCAT( "Valorizacion : ", date_format(now(), '%M %Y'))
      AND v.itembybudget_id = i.id
      AND i.item_id = im.id
      AND budget.id = va.budget_id
      AND im.cost_center_id = vi_cost_center_id
      GROUP BY type_article;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done6 = TRUE;
    OPEN valorizacion;
    read_loop6: LOOP
      FETCH valorizacion INTO v_article_code, v_amount;
      IF done6 THEN
        LEAVE read_loop6;
      END IF;
      SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%m%Y'),
        "`(`article_code`,`valorizado_specific_lvl_1`, `insertion_date`,`type`)
            VALUES ('",v_article_code, "',", v_amount,",'",DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"','GG');");
      PREPARE stmt FROM @SQL;
      EXECUTE stmt;
      DEALLOCATE PREPARE stmt;  
    END LOOP;
    CLOSE valorizacion;       
  END BLOCK6;
  -- GASTOS GENERALES VALORIZADO

  -- SERVICIOS GENERALES META
  BLOCKGE: BEGIN
    DECLARE donege INT DEFAULT FALSE;
    DECLARE meta CURSOR FOR 
      SELECT art.code, art.name, unit.symbol, CAST(ph.code AS CHAR), SUM( ged.parcial ), IFNULL(ged.people, ged.amount)
      FROM general_expense_details ged, general_expenses ge, articles art, unit_of_measurements unit, phases ph
      WHERE ged.general_expense_id = ge.id
      AND ge.cost_center_id = vi_cost_center_id
      AND DATE_FORMAT( ged.created_at,  '%Y-%m-%d' ) BETWEEN vi_start_date AND vi_end_date
      AND ge.code_phase > 90
      AND ge.phase_id = ph.id
      AND ged.article_id = art.id
      AND art.unit_of_measurement_id = unit.id
      GROUP BY (art.code);
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET donege = TRUE;
    OPEN meta;
    read_loop7: LOOP
      FETCH meta INTO v_article_code, v_article_name, v_article_unit, v_phase_code_hijo, v_amount, v_quantity;
      IF donege THEN
        LEAVE read_loop7;
      END IF;
      SET @phase_padre = (SELECT name FROM phases WHERE code = LEFT(v_phase_code_hijo,2));
      SET @phase_nombre = (SELECT name FROM phases WHERE code = v_phase_code_hijo);
      SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%m%Y'),
        "`(`article_code`,`article_name`,`article_unit`,`meta_specific_lvl_1`,
          `fase_cod_hijo`,`fase_cod_hijo_nombre`,`fase_cod_padre`,`fase_cod_padre_nombre`,
           `measured_meta`,`insertion_date`,`type`)
          VALUES (
            '",v_article_code, "','", v_article_name, "','", v_article_unit, "',", v_amount, ",'",
            v_phase_code_hijo,"','",@phase_nombre,"','",LEFT(v_phase_code_hijo,2),"','",@phase_padre,"',",
            v_quantity,",'",DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"', 'SG');");

      PREPARE stmt FROM @SQL;
      EXECUTE stmt;
      DEALLOCATE PREPARE stmt;               
    END LOOP;
    CLOSE meta;
  END BLOCKGE;
  
  BLOCKDEM: BEGIN
    DECLARE donedem INT DEFAULT FALSE;
    DECLARE meta CURSOR FOR 
      SELECT dem.article_code, art.name, unit.symbol, CAST(p.code AS CHAR), dem.amount
      FROM diverse_expenses_of_managements dem, diverse_expenses_of_management_details demd, articles art, unit_of_measurements unit, phases p
      WHERE dem.cost_center_id = vi_cost_center_id
      AND dem.id = demd.diverse_expenses_of_management_id
      AND dem.article_code = art.code
      AND dem.phase_id = p.id
      AND art.unit_of_measurement_id = unit.id
      AND DATE_FORMAT( dem.created_at,  '%Y-%m-%d' ) BETWEEN vi_start_date AND vi_end_date
      GROUP BY dem.article_code;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET donedem = TRUE;
    OPEN meta;
    read_loop8: LOOP
      FETCH meta INTO v_article_code, v_article_name, v_article_unit, v_phase_code_hijo, v_amount;
      IF donedem THEN
        LEAVE read_loop8;
      END IF;
      SET @phase_padre = (SELECT name FROM phases WHERE code = LEFT(v_phase_code_hijo,2));
      SET @phase_nombre = (SELECT name FROM phases WHERE code = v_phase_code_hijo);
      SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%m%Y'),
        "`(`article_code`,`article_name`,`article_unit`,`meta_specific_lvl_1`,
          `fase_cod_hijo`,`fase_cod_hijo_nombre`,`fase_cod_padre`,`fase_cod_padre_nombre`,
           `measured_meta`,`insertion_date`, `type`)
          VALUES (
            '",v_article_code, "','", v_article_name, "','", v_article_unit, "',", v_amount, ",'",
            v_phase_code_hijo,"','",@phase_nombre,"','",LEFT(v_phase_code_hijo,2),"','",@phase_padre,"',",
            1,",'",DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%Y-%m-%d'),"', 'SG');");

      PREPARE stmt FROM @SQL;
      EXECUTE stmt;
      DEALLOCATE PREPARE stmt;        
    END LOOP;
    CLOSE meta;
  END BLOCKDEM;
  -- SERVICIOS GENERALES META

  -- SERVICIOS GENERALES REAL
  -- STOCK OUPUTS
  BLOCKSI: BEGIN
    DECLARE donesi INT DEFAULT FALSE;
    DECLARE stock_outputs_gs CURSOR FOR 
      SELECT art.code, art.name, unit.symbol, CAST(p.code AS CHAR), CAST( se.code AS CHAR ) , (SUM(sid.amount)*stock_output_prices.price), SUM(sid.amount)
      FROM stock_inputs si, stock_input_details sid, phases p, articles art, unit_of_measurements unit, sectors se,
          (SELECT art.id AS artid, ((pod.unit_price_igv - IFNULL( pod.discount_after, 0 ) ) * dod.amount) AS price, dod.phase_id AS phases_dod, dod.sector_id AS sectordod
          FROM purchase_orders po, purchase_order_details pod, articles art, delivery_order_details dod, phases p
          WHERE po.id = pod.purchase_order_id
          AND po.cost_center_id = vi_cost_center_id
          AND pod.delivery_order_detail_id = dod.id
          AND dod.article_id = art.id
          AND po.state =  'approved'
          AND dod.phase_id = p.id
          AND p.code >  '91__'
          GROUP BY art.id) AS stock_output_prices
      WHERE si.id = sid.stock_input_id
      AND si.input = 0
      AND stock_output_prices.phases_dod = p.id
      AND si.status =  'A'
      AND stock_output_prices.sectordod = se.id
      AND si.cost_center_id = vi_cost_center_id
      AND sid.article_id = art.id
      AND sid.phase_id = p.id
      AND p.code > '91__'
      AND art.id = stock_output_prices.artid
      AND art.unit_of_measurement_id = unit.id
      AND DATE_FORMAT( si.issue_date,  '%Y-%m-%d' ) BETWEEN vi_start_date AND vi_end_date
      GROUP BY art.code;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET donesi = TRUE;
    OPEN stock_outputs_gs;
    read_loop9: LOOP
      FETCH stock_outputs_gs INTO v_article_code, v_article_name, v_article_unit, v_phase_code_hijo, v_sector_code_hijo, v_amount, v_quantity;
      IF donesi THEN
        LEAVE read_loop9;
      END IF;
      SET @phase_padre = (SELECT name FROM phases WHERE code = LEFT(v_phase_code_hijo,2));
      SET @phase_nombre = (SELECT name FROM phases WHERE code = v_phase_code_hijo);
      SET @sector_padre = (SELECT name FROM sectors WHERE code = LEFT(v_sector_code_hijo,2) AND cost_center_id = vi_cost_center_id);
      SET @sector_nombre = (SELECT name FROM sectors WHERE code = v_sector_code_hijo AND cost_center_id = vi_cost_center_id);

      SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%m%Y'),
        "`(`article_code`,`article_name`,`article_unit`,`real_specific_lvl_1`,
          `fase_cod_hijo`,`fase_cod_hijo_nombre`,`fase_cod_padre`,`fase_cod_padre_nombre`,
          `sector_cod_hijo`,`sector_cod_hijo_nombre`,`sector_cod_padre`,`sector_cod_padre_nombre`,
           `measured_real`,`insertion_date`, `type`)
          VALUES (
            '",v_article_code, "','", v_article_name, "','", v_article_unit, "',", v_total_h/v_pay*v_neto, ",'", 
            v_phase_code_hijo,"','",@phase_nombre,"','",LEFT(v_phase_code_hijo,2),"','",@phase_padre,"','",
            v_sector_code_hijo,"','",@sector_nombre,"','",LEFT(v_sector_code_hijo,2),"','",@sector_padre,"',",
            v_quantity,", '",vi_end_date,"', 'SG');");

      PREPARE stmt FROM @SQL;
      EXECUTE stmt;
      DEALLOCATE PREPARE stmt;               
    END LOOP;
    CLOSE stock_outputs_gs;
  END BLOCKSI;
  -- STOCK OUPUTS

  -- ORDER OF SERVICE
  BLOCKOS: BEGIN
    DECLARE doneos INT DEFAULT FALSE;
    DECLARE order_of_services CURSOR FOR 
      SELECT art.code, art.name, unit.symbol, CAST(p.code AS CHAR), CAST( se.code AS CHAR ) , osd.working_group_id, SUM(osd.unit_price_igv - IFNULL(osd.discount_after,0)), osd.amount
      FROM order_of_services os, order_of_service_details osd, phases p, articles art, unit_of_measurements unit, sectors se
      WHERE osd.phase_id = p.id
      AND os.id = osd.order_of_service_id
      AND os.cost_center_id = vi_cost_center_id
      AND osd.article_id = art.id
      AND se.id = osd.sector_id
      AND p.code > '91__'
      AND os.state =  'approved'
      AND art.unit_of_measurement_id = unit.id
      AND DATE_FORMAT( os.date_of_issue,  '%Y-%m-%d' ) BETWEEN vi_start_date AND vi_end_date
      GROUP BY LEFT(art.code, 2);
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET doneos = TRUE;
    OPEN order_of_services;
    read_loop10: LOOP
      FETCH order_of_services INTO v_article_code, v_article_name, v_article_unit, v_phase_code_hijo, v_sector_code_hijo, v_working_group, v_amount, v_quantity;
      IF doneos THEN
        LEAVE read_loop10;
      END IF;
      SET @phase_padre = (SELECT name FROM phases WHERE code = LEFT(v_phase_code_hijo,2));
      SET @phase_nombre = (SELECT name FROM phases WHERE code = v_phase_code_hijo);
      SET @sector_padre = (SELECT name FROM sectors WHERE code = LEFT(v_sector_code_hijo,2) AND cost_center_id = vi_cost_center_id);
      SET @sector_nombre = (SELECT name FROM sectors WHERE code = v_sector_code_hijo AND cost_center_id = vi_cost_center_id);

      SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_values_",vi_cost_center_id,"_",DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%m%Y'),
        "`(`article_code`,`article_name`,`article_unit`,`real_specific_lvl_1`,
          `fase_cod_hijo`,`fase_cod_hijo_nombre`,`fase_cod_padre`,`fase_cod_padre_nombre`,
          `sector_cod_hijo`,`sector_cod_hijo_nombre`,`sector_cod_padre`,`sector_cod_padre_nombre`,
           `measured_real`,`insertion_date`, `type`)
          VALUES (
            '",v_article_code, "','", v_article_name, "','", v_article_unit, "',", v_total_h/v_pay*v_neto, ",'", 
            v_phase_code_hijo,"','",@phase_nombre,"','",LEFT(v_phase_code_hijo,2),"','",@phase_padre,"','",
            v_sector_code_hijo,"','",@sector_nombre,"','",LEFT(v_sector_code_hijo,2),"','",@sector_padre,"',",
            v_quantity,", '",vi_end_date,"', 'SG');");

      PREPARE stmt FROM @SQL;
      EXECUTE stmt;
      DEALLOCATE PREPARE stmt;
    END LOOP;
    CLOSE order_of_services;
  END BLOCKOS;
  -- ORDER OF SERVICE
  -- SERVICIOS GENERALES REAL

END $$

DELIMITER ;
