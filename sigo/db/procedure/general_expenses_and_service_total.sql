DELIMITER $$

DROP PROCEDURE IF EXISTS `general_expenses_and_general_services_total`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `general_expenses_and_general_services_total`()
BEGIN
  DECLARE done INT DEFAULT FALSE;

  DECLARE val_dir_cost_hand_work FLOAT(10,2);
  DECLARE val_dir_cost_materials FLOAT(10,2);
  DECLARE val_dir_cost_equipment FLOAT(10,2);
  DECLARE val_dir_cost_subcontract FLOAT(10,2);
  DECLARE val_dir_cost_service FLOAT(10,2);

  DECLARE meta_dir_cost_hand_work FLOAT(10,2);
  DECLARE meta_dir_cost_materials FLOAT(10,2);
  DECLARE meta_dir_cost_equipment FLOAT(10,2);
  DECLARE meta_dir_cost_subcontract FLOAT(10,2);
  DECLARE meta_dir_cost_service FLOAT(10,2);

  DECLARE program_cost_hand_work FLOAT(10,2);
  DECLARE program_cost_materials FLOAT(10,2);
  DECLARE program_cost_equipment FLOAT(10,2);
  DECLARE program_cost_subcontract FLOAT(10,2);
  DECLARE program_cost_service FLOAT(10,2);

  DECLARE real_cost_hand_work FLOAT(10,2);
  DECLARE real_cost_materials FLOAT(10,2);
  DECLARE real_cost_equipment FLOAT(10,2);
  DECLARE real_cost_subcontract FLOAT(10,2);
  DECLARE real_cost_service FLOAT(10,2);  

  DECLARE m_hand_work FLOAT(10,2);
  DECLARE m_materials FLOAT(10,2);
  DECLARE m_equipment FLOAT(10,2);
  DECLARE m_subcontract FLOAT(10,2);
  DECLARE m_service FLOAT(10,2);

  DECLARE v_hand_work FLOAT(10,2);
  DECLARE v_materials FLOAT(10,2);
  DECLARE v_equipment FLOAT(10,2);
  DECLARE v_subcontract FLOAT(10,2);
  DECLARE v_service FLOAT(10,2);

  DECLARE r_hand_work FLOAT(10,2);
  DECLARE r_materials FLOAT(10,2);
  DECLARE r_equipment FLOAT(10,2);
  DECLARE r_subcontract FLOAT(10,2);
  DECLARE r_service FLOAT(10,2);

  DECLARE meta_hand_work FLOAT(10,2);
  DECLARE meta_materials FLOAT(10,2);
  DECLARE meta_equipment FLOAT(10,2);
  DECLARE meta_subcontract FLOAT(10,2);
  DECLARE meta_service FLOAT(10,2);

  DECLARE real_hand_work FLOAT(10,2);
  DECLARE real_materials FLOAT(10,2);
  DECLARE real_equipment FLOAT(10,2);
  DECLARE real_subcontract FLOAT(10,2);
  DECLARE real_service FLOAT(10,2);  

  DECLARE v_id INTEGER;
  DECLARE v_amount DOUBLE;
  DECLARE v_type_article TEXT;
  DECLARE table_for_insertion TEXT;

  DECLARE cost_centers CURSOR FOR 
    SELECT id FROM cost_centers WHERE active = 1 AND status = "A";
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  SET val_dir_cost_hand_work = 0.0;
  SET val_dir_cost_materials = 0.0;
  SET val_dir_cost_equipment = 0.0;
  SET val_dir_cost_subcontract = 0.0;
  SET val_dir_cost_service = 0.0;

  SET meta_dir_cost_hand_work = 0.0;
  SET meta_dir_cost_materials = 0.0;
  SET meta_dir_cost_equipment = 0.0;
  SET meta_dir_cost_subcontract = 0.0;
  SET meta_dir_cost_service = 0.0;

  SET program_cost_hand_work = 0.0;
  SET program_cost_materials = 0.0;
  SET program_cost_equipment = 0.0;
  SET program_cost_subcontract = 0.0;
  SET program_cost_service   = 0.0;

  SET real_cost_hand_work = 0.0;
  SET real_cost_materials = 0.0;
  SET real_cost_equipment = 0.0;
  SET real_cost_subcontract = 0.0;
  SET real_cost_service = 0.0;

  SET m_hand_work = 0.0;
  SET m_materials = 0.0;
  SET m_equipment = 0.0;
  SET m_subcontract = 0.0;
  SET m_service = 0.0;
  SET v_hand_work = 0.0;
  SET v_materials = 0.0;
  SET v_equipment = 0.0;
  SET v_subcontract = 0.0;
  SET v_service = 0.0;
  SET r_hand_work = 0.0;
  SET r_materials = 0.0;
  SET r_equipment = 0.0;
  SET r_subcontract = 0.0;
  SET r_service = 0.0;

  SET meta_hand_work = 0.0;
  SET meta_materials = 0.0;
  SET meta_equipment = 0.0;
  SET meta_subcontract = 0.0;
  SET meta_service = 0.0;
  SET real_hand_work = 0.0;
  SET real_materials = 0.0;
  SET real_equipment = 0.0;
  SET real_subcontract = 0.0;
  SET real_service = 0.0;

  OPEN cost_centers;
  read_loop: LOOP
    FETCH cost_centers INTO v_id;
    IF done THEN
      LEAVE read_loop;
    END IF;

    -- COSTO DIRECTO VALORIZADO
    BLOCKVAL: BEGIN
      DECLARE done_val_dir_cost INT DEFAULT FALSE;
      DECLARE ibi_done_val_dir_cost INT DEFAULT FALSE;

      DECLARE v_valorization_id INT;
      DECLARE v_budget_id INT;
      DECLARE v_order CHAR(120);
      DECLARE v_description CHAR(255);
      DECLARE v_measured FLOAT(10,4);

      DECLARE valorizations CURSOR FOR
        SELECT v.id, b.id 
        FROM valorizations v, budgets b 
        WHERE b.cost_center_id = v_id
        AND b.type_of_budget = 1
        AND b.id = v.budget_id
        AND v.valorization_date BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY);
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_val_dir_cost = TRUE;

      OPEN valorizations;
      read_loopdc_val: LOOP
        FETCH valorizations INTO v_valorization_id, v_budget_id;
        IF done_val_dir_cost THEN
          LEAVE read_loopdc_val;
        END IF;

        -- MONTOS VALORIZADOS
        BLOCK: BEGIN
          DECLARE itembybudgets CURSOR FOR
          SELECT rv.order, description, con_measured FROM report_valorizations rv WHERE valorization_id = v_valorization_id AND con_measured IS NOT NULL;
          DECLARE CONTINUE HANDLER FOR NOT FOUND SET ibi_done_val_dir_cost = TRUE;
        
          OPEN itembybudgets;
          read_loop_ibb: LOOP
          FETCH itembybudgets INTO v_order, v_description, v_measured;
            IF ibi_done_val_dir_cost THEN
              LEAVE read_loop_ibb;
            END IF;

            SET @i_identify = (SELECT p.id FROM itembywbses ibw, wbsitems wi, phases p WHERE ibw.wbsitem_id = wi.id AND p.code > '0___' AND p.code < '89__' AND wi.phase_id = p.id AND ibw.budget_id = v_budget_id AND ibw.order_budget LIKE v_order GROUP BY p.id);

          IF @i_identify IS NOT NULL THEN
            SET @val_dir_cost_hand_work = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '01%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
            SET val_dir_cost_hand_work  = IFNULL(val_dir_cost_hand_work, 0) + IFNULL(@val_dir_cost_hand_work, 0);

            SET @val_dir_cost_materials = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '02%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
            SET val_dir_cost_materials  = IFNULL(val_dir_cost_materials, 0) + IFNULL(@val_dir_cost_materials, 0);

            SET @val_dir_cost_equipment = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '03%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
            SET val_dir_cost_equipment  = IFNULL(val_dir_cost_equipment, 0) + IFNULL(@val_dir_cost_equipment, 0);

            SET @val_dir_cost_subcontract = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '04%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
            SET val_dir_cost_subcontract  = IFNULL(val_dir_cost_subcontract, 0) + IFNULL(@val_dir_cost_subcontract, 0);

            SET @val_dir_cost_service = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '05%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
            SET val_dir_cost_service  = IFNULL(val_dir_cost_service, 0) + IFNULL(@val_dir_cost_service, 0);

          END IF;

          END LOOP read_loop_ibb;
          CLOSE itembybudgets;
        END BLOCK;

      END LOOP read_loopdc_val;
      CLOSE valorizations;
    END BLOCKVAL;
    -- COSTO DIRECTO VALORIZADO

    -- COSTO DIRECTO META
    BLOCKMETA: BEGIN
      DECLARE done_meta_dir_cos INT DEFAULT FALSE;

      DECLARE v_itembybudget_id INT;
      DECLARE v_budget_id INT;
      DECLARE v_order CHAR(120);

      DECLARE itembybudgets CURSOR FOR -- ESTO SACA DATOS CON ibb.id REPETIDOS
      SELECT ibb.id, ibb.budget_id, ibb.order
      FROM part_works pw, part_work_details pwd, itembybudgets ibb
      WHERE pw.cost_center_id = v_id 
      AND pw.date_of_creation BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY)
      AND pw.id = pwd.part_work_id
      AND pwd.itembybudget_id = ibb.id;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_meta_dir_cos = TRUE;

      -- MONTOS META
      OPEN itembybudgets;
      read_loop_dcm: LOOP
        FETCH itembybudgets INTO v_itembybudget_id, v_budget_id, v_order;
        IF done_meta_dir_cos THEN
          LEAVE read_loop_dcm;
        END IF;
      
        SET @i_identify = (SELECT p.id FROM itembywbses ibw, wbsitems wi, phases p WHERE ibw.wbsitem_id = wi.id AND p.code > '0___' AND p.code < '89__' AND wi.phase_id = p.id AND ibw.budget_id = v_budget_id AND ibw.order_budget LIKE v_order GROUP BY p.id);

        IF @i_identify IS NOT NULL THEN
          SET @meta_dir_cost_hand_work = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '01%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
          SET meta_dir_cost_hand_work  = IFNULL(meta_dir_cost_hand_work, 0) + IFNULL(@meta_dir_cost_hand_work, 0);

          SET @meta_dir_cost_materials = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '02%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
          SET meta_dir_cost_materials  = IFNULL(meta_dir_cost_materials, 0) + IFNULL(@meta_dir_cost_materials, 0);

          SET @meta_dir_cost_equipment = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '03%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
          SET meta_dir_cost_equipment  = IFNULL(meta_dir_cost_equipment, 0) + IFNULL(@meta_dir_cost_equipment, 0);

          SET @meta_dir_cost_subcontract = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '04%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
          SET meta_dir_cost_subcontract  = IFNULL(meta_dir_cost_subcontract, 0) + IFNULL(@meta_dir_cost_subcontract, 0);

          SET @meta_dir_cost_service = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '05%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
          SET meta_dir_cost_service  = IFNULL(meta_dir_cost_service, 0) + IFNULL(@meta_dir_cost_service, 0);
        END IF;

      END LOOP read_loop_dcm;
      CLOSE itembybudgets;
    END BLOCKMETA;
    -- COSTO DIRECTO META

    -- COSTO DIRECTO REAL
    BLOCK3dc: BEGIN
      DECLARE donedc3 INT DEFAULT FALSE;
      DECLARE stock_outputs_dc CURSOR FOR 
        SELECT LEFT( art.code, 2 ) as code_article , (SUM(pod.unit_price_igv-IFNULL(pod.discount_after,0))/SUM(dod.amount)*stock_output.amount)
        FROM articles art, purchase_orders po, purchase_order_details pod, delivery_order_details dod, phases p,
              (SELECT art.id AS article_id, SUM( sid.amount ) AS amount
              FROM stock_inputs si, stock_input_details sid, articles art
              WHERE si.input = 0
              AND si.cost_center_id = v_id
              AND si.status =  'A'
              AND sid.stock_input_id = si.id
              AND si.issue_date BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY)
              AND sid.article_id = art.id
              GROUP BY art.id) AS stock_output
        WHERE dod.article_id = stock_output.article_id
        AND art.id = dod.article_id
        AND dod.phase_id = p.id
        AND p.code  > '0___' AND p.code < '89__'
        AND pod.delivery_order_detail_id = dod.id
        AND po.id = pod.purchase_order_id
        AND po.cost_center_id = v_id
        GROUP BY art.id;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET donedc3 = TRUE;
      OPEN stock_outputs_dc;
      read_loop3dc: LOOP
        FETCH stock_outputs_dc INTO v_type_article, v_amount;
        IF donedc3 THEN
          LEAVE read_loop3dc;
        END IF;
        IF v_type_article = "01" THEN
          SET real_cost_hand_work = IFNULL(v_amount, 0) + IFNULL(real_cost_hand_work, 0);
        END IF;
        IF v_type_article = "02" THEN
          SET real_cost_materials = IFNULL(v_amount, 0) + IFNULL(real_cost_materials, 0);
        END IF;
        IF v_type_article = "03" THEN
          SET real_cost_equipment = IFNULL(v_amount, 0) + IFNULL(real_cost_equipment, 0);
        END IF;        
        IF v_type_article = "04" THEN
          SET real_cost_subcontract = IFNULL(v_amount, 0) + IFNULL(real_cost_subcontract, 0);
        END IF;
        IF v_type_article = "05" THEN
          SET real_cost_service = IFNULL(v_amount, 0) + IFNULL(real_cost_service, 0);
        END IF;              
      END LOOP read_loop3dc;
      CLOSE stock_outputs_dc;
    END BLOCK3dc;

    BLOCK4dc: BEGIN
      DECLARE done4dc INT DEFAULT FALSE;
      DECLARE order_of_servicesdc CURSOR FOR 
        SELECT LEFT(art.code, 2), SUM(osd.unit_price_igv - IFNULL(osd.discount_after,0))
        FROM order_of_service_details osd, phases p, order_of_services os, articles art
        WHERE osd.phase_id = p.id
        AND os.id = osd.order_of_service_id
        AND os.date_of_issue BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY)
        AND os.cost_center_id = v_id
        AND osd.article_id = art.id
        AND p.code  > '0___' AND p.code < '89__'
        AND os.state =  'approved'
        GROUP BY LEFT(art.code, 2);
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done4dc = TRUE;
      OPEN order_of_servicesdc;
      read_loop4dc: LOOP
        FETCH order_of_servicesdc INTO v_type_article, v_amount;
        IF done4dc THEN
          LEAVE read_loop4dc;
        END IF;
        IF v_type_article = "01" THEN
          SET real_cost_hand_work = IFNULL(v_amount, 0) + IFNULL(real_cost_hand_work, 0);
        END IF;
        IF v_type_article = "02" THEN
          SET real_cost_materials = IFNULL(v_amount, 0) + IFNULL(real_cost_materials, 0);
        END IF;
        IF v_type_article = "03" THEN
          SET real_cost_equipment = IFNULL(v_amount, 0) + IFNULL(real_cost_equipment, 0);
        END IF;        
        IF v_type_article = "04" THEN
          SET real_cost_subcontract = IFNULL(v_amount, 0) + IFNULL(real_cost_subcontract, 0);
        END IF;
        IF v_type_article = "05" THEN
          SET real_cost_service = IFNULL(v_amount, 0) + IFNULL(real_cost_service, 0);
        END IF;              
      END LOOP read_loop4dc;
      CLOSE order_of_servicesdc;
    END BLOCK4dc;

    BLOCK5dc: BEGIN
      DECLARE done5dc INT DEFAULT FALSE;
      DECLARE done5dcpw INT DEFAULT FALSE;

      DECLARE v_worker INT;
      DECLARE v_total_h FLOAT(10,2);
      DECLARE v_neto FLOAT(10,2);
      DECLARE v_date_begin DATE;
      DECLARE v_date_end DATE;
      -- part_people
      DECLARE payrolldc CURSOR FOR 
        SELECT ppd.worker_id, SUM(ppd.total_hours), payslips_worker.Neto, payslips_worker.date_begin, payslips_worker.date_end 
        FROM part_people pp, part_person_details ppd, phases p,
          (SELECT p.worker_id AS worker_id, p.date_begin AS date_begin, p.date_end AS date_end, IFNULL(SUM(CAST(REPLACE( SUBSTRING_INDEX( aport_and_amounts, '","', 1 ) , '{"neto":"', '' ) as DECIMAL(9,2))),0) AS Neto
           FROM payslips p
           WHERE p.cost_center_id = v_id
           AND p.date_begin BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY)
           GROUP BY p.worker_id) AS payslips_worker
        WHERE ppd.part_person_id = pp.id
        AND payslips_worker.worker_id = ppd.worker_id
        AND pp.blockweekly = 1
        AND pp.cost_center_id = v_id
        AND ppd.phase_id = p.id
        AND pp.date_of_creation BETWEEN payslips_worker.date_begin AND payslips_worker.date_end
        GROUP BY ppd.worker_id;
      -- part_people

      -- part_workers      
      DECLARE payrollpwdc CURSOR FOR 
        SELECT pwd.worker_id, SUM( 8.5 ), payslips_worker.Neto, payslips_worker.date_begin, payslips_worker.date_end 
        FROM part_workers pw, part_worker_details pwd,
          (SELECT p.worker_id AS worker_id, p.date_begin AS date_begin, p.date_end AS date_end, IFNULL(SUM(CAST(REPLACE( SUBSTRING_INDEX( aport_and_amounts, '","', 1 ) , '{"neto":"', '' ) as DECIMAL(9,2))),0) AS Neto
           FROM payslips p
           WHERE p.cost_center_id = v_id
           AND p.date_begin BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY)
           GROUP BY p.worker_id) AS payslips_worker
        WHERE pw.cost_center_id = v_id
        AND pw.id = pwd.part_worker_id
        AND payslips_worker.worker_id = pwd.worker_id
        AND pwd.assistance =  'si'
        AND pw.blockweekly = 1
        AND pw.date_of_creation BETWEEN payslips_worker.date_begin AND payslips_worker.date_end
        GROUP BY pwd.worker_id;
      -- part_workers
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done5dc = TRUE;        

      -- part_people
      OPEN payrolldc;
      read_loop5dc: LOOP
        FETCH payrolldc INTO v_worker, v_total_h, v_neto, v_date_begin, v_date_end;
        IF done5dc THEN
          LEAVE read_loop5dc;
        END IF;
        SET @real_cost_hand_work = (SELECT SUM(ppd.total_hours) FROM part_people pp, part_person_details ppd, phases p WHERE ppd.part_person_id = pp.id AND ppd.worker_id = v_worker AND pp.blockweekly = 1 AND pp.cost_center_id = v_id AND ppd.phase_id = p.id AND pp.date_of_creation BETWEEN v_date_begin AND v_date_end AND p.code < '90__' GROUP BY ppd.worker_id);
        IF @real_cost_hand_work != NULL THEN
          SET real_cost_hand_work = real_cost_hand_work + v_total_h/@real_cost_hand_work*v_neto;
        END IF;
      END LOOP read_loop5dc;
      CLOSE payrolldc;
      -- part_people
      SET done5dc = 0;
      -- part_workers
      OPEN payrollpwdc;
      read_loop5dcpw: LOOP
        FETCH payrollpwdc INTO v_worker, v_total_h, v_neto, v_date_begin, v_date_end;
        IF done5dc THEN
          LEAVE read_loop5dcpw;
        END IF;
        SET @real_cost_hand_work = (SELECT SUM(8.5) FROM part_workers pw, part_worker_details pwd, phases p WHERE pwd.part_worker_id = pp.id AND pwd.worker_id = v_worker AND pw.blockweekly = 1 AND pw.cost_center_id = v_id AND pwd.phase_id = p.id AND pw.date_of_creation BETWEEN v_date_begin AND v_date_end AND p.code < '90__' GROUP BY pwd.worker_id);
        IF @real_cost_hand_work != NULL THEN
          SET real_cost_hand_work = real_cost_hand_work + v_total_h/@real_cost_hand_work*v_neto;
        END IF;
      END LOOP read_loop5dcpw;
      CLOSE payrollpwdc;
      -- part_workers

    END BLOCK5dc;
    -- COSTO DIRECTO REAL    

    -- COSTO DIRECTO PROGRAMADO
    BLOCKPROG: BEGIN
      DECLARE done_program INT DEFAULT FALSE;

      DECLARE v_order CHAR(120);
      DECLARE v_measured FLOAT(10,2);
      DECLARE v_budget_id INT;

      DECLARE distributions CURSOR FOR -- ESTO SACA DATOS CON ibb.id REPETIDOS
      SELECT d.code as 'budgetCode', di.value as 'measured', d.budget_id 'budgetId' 
      FROM distributions d, distribution_items di 
      WHERE di.distribution_id = d.id 
      AND di.month BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY)
      AND d.cost_center_id = v_id 
      AND di.value IS NOT NULL;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_program = TRUE;

      OPEN distributions;
      read_loop_program: LOOP
        FETCH distributions INTO v_order, v_measured, v_budget_id;
        IF done_program THEN
          LEAVE read_loop_program;
        END IF;

        SET @program_cost_hand_work = (SELECT SUM( ibi.quantity * ibi.price * v_measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '01%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
        SET program_cost_hand_work  = IFNULL(program_cost_hand_work, 0) + IFNULL(@program_cost_hand_work, 0);

        SET @program_cost_materials = (SELECT SUM( ibi.quantity * ibi.price * v_measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '02%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
        SET program_cost_materials  = IFNULL(program_cost_materials, 0) + IFNULL(@program_cost_materials, 0);

        SET @program_cost_equipment = (SELECT SUM( ibi.quantity * ibi.price * v_measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '03%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
        SET program_cost_equipment  = IFNULL(program_cost_equipment, 0) + IFNULL(@program_cost_equipment, 0);

        SET @program_cost_subcontract = (SELECT SUM( ibi.quantity * ibi.price * v_measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '04%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
        SET program_cost_subcontract  = IFNULL(program_cost_subcontract, 0) + IFNULL(@program_cost_subcontract, 0);

        SET @program_cost_service = (SELECT SUM( ibi.quantity * ibi.price * v_measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '05%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
        SET program_cost_service  = IFNULL(program_cost_service, 0) + IFNULL(@program_cost_service, 0);

      END LOOP read_loop_program;
      CLOSE distributions;    
    END BLOCKPROG;
    -- COSTO DIRECTO PROGRAMADO    

    -- GASTOS GENERALES META
    BLOCK2: BEGIN
      DECLARE done2 INT DEFAULT FALSE;
      DECLARE meta CURSOR FOR 
        SELECT ged.type_article, SUM( ged.parcial ) 
        FROM general_expense_details ged, general_expenses ge
        WHERE ged.general_expense_id = ge.id
        AND ge.cost_center_id = v_id
        AND DATE_FORMAT( ged.created_at,  '%Y-%m-%d' ) BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY)
        AND ge.code_phase = 90
        GROUP BY (ged.type_article);
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done2 = TRUE;
      OPEN meta;
      read_loop2: LOOP
        FETCH meta INTO v_type_article, v_amount;
        IF done2 THEN
          LEAVE read_loop2;
        END IF;
        IF v_type_article = "01" THEN
          SET m_hand_work = v_amount;
        END IF;
        IF v_type_article = "02" THEN
          SET m_materials = v_amount;
        END IF;
        IF v_type_article = "03" THEN
          SET m_equipment = v_amount;
        END IF;        
        IF v_type_article = "04" THEN
          SET m_subcontract = v_amount;
        END IF;
        IF v_type_article = "05" THEN
          SET m_service = v_amount;
        END IF;              
      END LOOP;
      CLOSE meta;
    END BLOCK2;
    -- GASTOS GENERALES META

    -- GASTOS GENERALES REAL
    -- STOCK OUTPUTS
    BLOCK3: BEGIN
      DECLARE done3 INT DEFAULT FALSE;
      DECLARE stock_outputs CURSOR FOR 
        SELECT LEFT( art.code, 2 ) as code_article , (SUM(pod.unit_price_igv-IFNULL(pod.discount_after,0))/SUM(dod.amount)*stock_output.amount)
        FROM articles art, purchase_orders po, purchase_order_details pod, delivery_order_details dod, phases p,
             (SELECT art.id AS article_id, SUM( sid.amount ) AS amount
              FROM stock_inputs si, stock_input_details sid, articles art
              WHERE si.input = 0
              AND si.cost_center_id = v_id
              AND si.status =  'A'
              AND sid.stock_input_id = si.id
              AND si.issue_date BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY)
              AND sid.article_id = art.id
              GROUP BY art.id) AS stock_output
        WHERE dod.article_id = stock_output.article_id
        AND art.id = dod.article_id
        AND dod.phase_id = p.id
        AND p.code LIKE '90__'
        AND pod.delivery_order_detail_id = dod.id
        AND po.id = pod.purchase_order_id
        AND po.cost_center_id = v_id
        GROUP BY art.id;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done3 = TRUE;
      OPEN stock_outputs;
      read_loop3: LOOP
        FETCH stock_outputs INTO v_type_article, v_amount;
        IF done3 THEN
          LEAVE read_loop3;
        END IF;
        IF v_type_article = "01" THEN
          SET r_hand_work = v_amount + r_hand_work;
        END IF;
        IF v_type_article = "02" THEN
          SET r_materials = v_amount + r_materials;
        END IF;
        IF v_type_article = "03" THEN
          SET r_equipment = v_amount + r_equipment;
        END IF;        
        IF v_type_article = "04" THEN
          SET r_subcontract = v_amount + r_subcontract;
        END IF;
        IF v_type_article = "05" THEN
          SET r_service = v_amount + r_service;
        END IF;              
      END LOOP;
      CLOSE stock_outputs;
    END BLOCK3;
    -- STOCK OUTPUTS

    -- ORDER OF SERVICE
    BLOCK4: BEGIN
      DECLARE done4 INT DEFAULT FALSE;
      DECLARE order_of_services CURSOR FOR 
        SELECT LEFT(art.code, 2), SUM(osd.unit_price_igv - IFNULL(osd.discount_after,0))
        FROM order_of_service_details osd, phases p, order_of_services os, articles art
        WHERE osd.phase_id = p.id
        AND os.id = osd.order_of_service_id
        AND os.date_of_issue BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY)
        AND os.cost_center_id = v_id
        AND osd.article_id = art.id
        AND p.code LIKE  '90__'
        AND os.state =  'approved'
        GROUP BY LEFT(art.code, 2);
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done4 = TRUE;
      OPEN order_of_services;
      read_loop4: LOOP
        FETCH order_of_services INTO v_type_article, v_amount;
        IF done4 THEN
          LEAVE read_loop4;
        END IF;
        IF v_type_article = "01" THEN
          SET r_hand_work = v_amount + r_hand_work;
        END IF;
        IF v_type_article = "02" THEN
          SET r_materials = v_amount + r_materials;
        END IF;
        IF v_type_article = "03" THEN
          SET r_equipment = v_amount + r_equipment;
        END IF;        
        IF v_type_article = "04" THEN
          SET r_subcontract = v_amount + r_subcontract;
        END IF;
        IF v_type_article = "05" THEN
          SET r_service = v_amount + r_service;
        END IF;              
      END LOOP;
      CLOSE order_of_services;
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
           WHERE p.cost_center_id = v_id
           AND p.date_begin BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY)
           GROUP BY p.worker_id) AS payslips_worker
        WHERE ppd.part_person_id = pp.id
        AND payslips_worker.worker_id = ppd.worker_id
        AND pp.blockweekly = 1
        AND pp.cost_center_id = v_id
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
           WHERE p.cost_center_id = v_id
           AND p.date_begin BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY)
           GROUP BY p.worker_id) AS payslips_worker
        WHERE pw.cost_center_id = v_id
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
        SET @r_hand_work = (SELECT SUM(ppd.total_hours) FROM part_people pp, part_person_details ppd, phases p WHERE ppd.part_person_id = pp.id AND ppd.worker_id = v_worker AND pp.blockweekly = 1 AND pp.cost_center_id = v_id AND ppd.phase_id = p.id AND pp.date_of_creation BETWEEN v_date_begin AND v_date_end AND p.code LIKE  '90__' GROUP BY ppd.worker_id);
        IF @r_hand_work != NULL THEN
          SET r_hand_work = r_hand_work + v_total_h/@r_hand_work*v_neto;
        END IF;
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
        SET @r_hand_work = (SELECT SUM(8.5) FROM part_workers pw, part_worker_details pwd, phases p WHERE pwd.part_worker_id = pp.id AND pwd.worker_id = v_worker AND pw.blockweekly = 1 AND pw.cost_center_id = v_id AND pwd.phase_id = p.id AND pw.date_of_creation BETWEEN v_date_begin AND v_date_end AND p.code LIKE '90__' GROUP BY pwd.worker_id);
        IF @r_hand_work != NULL THEN
          SET r_hand_work = r_hand_work + v_total_h/@r_hand_work*v_neto;
        END IF;
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
        SELECT LEFT( im.item_code, 2 ) AS type_article, SUM( i.measured * i.price )*budget.general_expenses
        FROM valorizations va, valorizationitems v, itembybudgets i, items im, 
             (SELECT b.id, b.general_expenses
              FROM budgets b
              WHERE b.cost_center_id = v_id
              AND b.type_of_budget = 1
           ) AS budget
        WHERE v.valorization_id = va.id
        AND va.budget_id = budget.id
        AND va.month LIKE CONCAT( "Valorizacion : ", date_format(now(), '%M %Y'))
        AND v.itembybudget_id = i.id
        AND i.item_id = im.id
        AND budget.id = va.budget_id
        AND im.cost_center_id = v_id
        GROUP BY type_article;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done6 = TRUE;
      OPEN valorizacion;
      read_loop6: LOOP
        FETCH valorizacion INTO v_type_article, v_amount;
        IF done6 THEN
          LEAVE read_loop6;
        END IF;
        IF v_type_article = "01" THEN
          SET v_hand_work = v_amount;
        END IF;
        IF v_type_article = "02" THEN
          SET v_materials = v_amount;
        END IF;
        IF v_type_article = "03" THEN
          SET v_equipment = v_amount;
        END IF;        
        IF v_type_article = "04" THEN
          SET v_subcontract = v_amount;
        END IF;
        IF v_type_article = "05" THEN
          SET v_service = v_amount;
        END IF; 
      END LOOP;
      CLOSE valorizacion;       
    END BLOCK6;
    -- GASTOS GENERALES VALORIZADO

    -- SERVICIOS GENERALES META
    BLOCKGE: BEGIN
      DECLARE donege INT DEFAULT FALSE;
      DECLARE meta CURSOR FOR 
        SELECT ged.type_article, SUM( ged.parcial ) 
        FROM general_expenses ge, general_expense_details ged
        WHERE ge.cost_center_id = v_id
        AND ge.id = ged.general_expense_id
        AND ge.code_phase > 90
        AND DATE_FORMAT( ge.created_at,  '%Y-%m-%d' ) BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY)
        GROUP BY ged.type_article;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET donege = TRUE;
      OPEN meta;
      read_loop7: LOOP
        FETCH meta INTO v_type_article, v_amount;
        IF donege THEN
          LEAVE read_loop7;
        END IF;
        IF v_type_article = "01" THEN
          SET meta_hand_work = v_amount;
        END IF;
        IF v_type_article = "02" THEN
          SET meta_materials = v_amount;
        END IF;
        IF v_type_article = "03" THEN
          SET meta_equipment = v_amount;
        END IF;        
        IF v_type_article = "04" THEN
          SET meta_subcontract = v_amount;
        END IF;
        IF v_type_article = "05" THEN
          SET meta_service = v_amount;
        END IF;              
      END LOOP;
      CLOSE meta;
    END BLOCKGE;
    
    BLOCKDEM: BEGIN
      DECLARE donedem INT DEFAULT FALSE;
      DECLARE meta CURSOR FOR 
        SELECT LEFT(dem.article_code, 2), SUM( demd.amount ) 
        FROM diverse_expenses_of_managements dem, diverse_expenses_of_management_details demd
        WHERE dem.cost_center_id = v_id
        AND dem.id = demd.diverse_expenses_of_management_id
        AND DATE_FORMAT( dem.created_at,  '%Y-%m-%d' ) BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY)
        GROUP BY LEFT(dem.article_code, 2);
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET donedem = TRUE;
      OPEN meta;
      read_loop8: LOOP
        FETCH meta INTO v_type_article, v_amount;
        IF donedem THEN
          LEAVE read_loop8;
        END IF;
        IF v_type_article = "01" THEN
          SET meta_hand_work = v_amount;
        END IF;
        IF v_type_article = "02" THEN
          SET meta_materials = v_amount;
        END IF;
        IF v_type_article = "03" THEN
          SET meta_equipment = v_amount;
        END IF;        
        IF v_type_article = "04" THEN
          SET meta_subcontract = v_amount;
        END IF;
        IF v_type_article = "05" THEN
          SET meta_service = v_amount;
        END IF;              
      END LOOP;
      CLOSE meta;
    END BLOCKDEM;
    -- SERVICIOS GENERALES META

    -- SERVICIOS GENERALES REAL
    -- STOCK OUPUTS
    BLOCKSI: BEGIN
      DECLARE donesi INT DEFAULT FALSE;
      DECLARE stock_outputs_gs CURSOR FOR 
        SELECT LEFT(art.code, 2), (SUM(sid.amount)*stock_output_prices.price)
        FROM stock_inputs si, stock_input_details sid, phases p, articles art,
            (SELECT art.id AS artid, ((pod.unit_price_igv - IFNULL( pod.discount_after, 0 ) ) * dod.amount) AS price
            FROM purchase_orders po, purchase_order_details pod, articles art, delivery_order_details dod, phases p
            WHERE po.id = pod.purchase_order_id
            AND po.cost_center_id = v_id
            AND pod.delivery_order_detail_id = dod.id
            AND dod.article_id = art.id
            AND po.state =  'approved'
            AND dod.phase_id = p.id
            AND p.code >  '91__'
            GROUP BY art.id) AS stock_output_prices
        WHERE si.id = sid.stock_input_id
        AND si.input = 0
        AND si.status =  'A'
        AND si.cost_center_id = v_id
        AND sid.article_id = art.id
        AND sid.phase_id = p.id
        AND p.code > '91__'
        AND art.id = stock_output_prices.artid
        AND DATE_FORMAT( si.issue_date,  '%Y-%m-%d' ) BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY)
        GROUP BY LEFT(art.code, 2);
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET donesi = TRUE;
      OPEN stock_outputs_gs;
      read_loop9: LOOP
        FETCH stock_outputs_gs INTO v_type_article, v_amount;
        IF donesi THEN
          LEAVE read_loop9;
        END IF;
        IF v_type_article = "01" THEN
          SET real_hand_work = v_amount;
        END IF;
        IF v_type_article = "02" THEN
          SET real_materials = v_amount;
        END IF;
        IF v_type_article = "03" THEN
          SET real_equipment = v_amount;
        END IF;        
        IF v_type_article = "04" THEN
          SET real_subcontract = v_amount;
        END IF;
        IF v_type_article = "05" THEN
          SET real_service = v_amount;
        END IF;              
      END LOOP;
      CLOSE stock_outputs_gs;
    END BLOCKSI;
    -- STOCK OUPUTS

    -- ORDER OF SERVICE
    BLOCKOS: BEGIN
      DECLARE doneos INT DEFAULT FALSE;
      DECLARE order_of_services CURSOR FOR 
        SELECT LEFT(art.code, 2), SUM(osd.unit_price_igv - IFNULL(osd.discount_after,0))
        FROM order_of_services os, order_of_service_details osd, phases p, articles art
        WHERE osd.phase_id = p.id
        AND os.id = osd.order_of_service_id
        AND os.cost_center_id = v_id
        AND osd.article_id = art.id
        AND p.code > '91__'
        AND os.state =  'approved'
        AND DATE_FORMAT( os.date_of_issue,  '%Y-%m-%d' ) BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY)
        GROUP BY LEFT(art.code, 2);
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET doneos = TRUE;
      OPEN order_of_services;
      read_loop10: LOOP
        FETCH order_of_services INTO v_type_article, v_amount;
        IF doneos THEN
          LEAVE read_loop10;
        END IF;
        IF v_type_article = "01" THEN
          SET real_hand_work = v_amount + real_hand_work;
        END IF;
        IF v_type_article = "02" THEN
          SET real_materials = v_amount + real_materials;
        END IF;
        IF v_type_article = "03" THEN
          SET real_equipment = v_amount + real_equipment;
        END IF;        
        IF v_type_article = "04" THEN
          SET real_subcontract = v_amount + real_subcontract;
        END IF;
        IF v_type_article = "05" THEN
          SET real_service = v_amount + real_service;
        END IF;              
      END LOOP;
      CLOSE order_of_services;
    END BLOCKOS;
    -- ORDER OF SERVICE

    -- PAYROLLS
    BLOCKPAY: BEGIN
      DECLARE donepay INT DEFAULT FALSE;
      DECLARE donepaypw INT DEFAULT FALSE;      

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
           WHERE p.cost_center_id = v_id
           AND p.date_begin BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY)
           GROUP BY p.worker_id) AS payslips_worker
        WHERE ppd.part_person_id = pp.id
        AND payslips_worker.worker_id = ppd.worker_id
        AND pp.blockweekly = 1
        AND pp.cost_center_id = v_id
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
           WHERE p.cost_center_id = v_id
           AND p.date_begin BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY)
           GROUP BY p.worker_id) AS payslips_worker
        WHERE pw.cost_center_id = v_id
        AND pw.id = pwd.part_worker_id
        AND payslips_worker.worker_id = pwd.worker_id
        AND pwd.assistance =  'si'
        AND pw.blockweekly = 1
        AND pw.date_of_creation BETWEEN payslips_worker.date_begin AND payslips_worker.date_end
        GROUP BY pwd.worker_id;
      -- part_workers
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET donepay = TRUE;
      
      -- part_people      
      OPEN payroll;
      read_loop11: LOOP
        FETCH payroll INTO v_worker, v_total_h, v_neto, v_date_begin, v_date_end;
        IF donepay THEN
          LEAVE read_loop11;
        END IF;
        SET @real_hand_work = (SELECT SUM(ppd.total_hours) FROM part_people pp, part_person_details ppd, phases p WHERE ppd.part_person_id = pp.id AND ppd.worker_id = v_worker AND pp.blockweekly = 1 AND pp.cost_center_id = v_id AND ppd.phase_id = p.id AND pp.date_of_creation BETWEEN v_date_begin AND v_date_end AND p.code > '91__' GROUP BY ppd.worker_id);
        IF @real_hand_work != NULL THEN
          SET real_hand_work = real_hand_work + v_total_h/@real_hand_work*v_neto;
        END IF;
      END LOOP;
      CLOSE payroll;  
      -- part_people
      SET donepay = 0;
      -- part_workers
      OPEN payrollpw;
      read_loop5pw: LOOP
        FETCH payrollpw INTO v_worker, v_total_h, v_neto, v_date_begin, v_date_end;
        IF donepay THEN
          LEAVE read_loop5pw;
        END IF;
        SET @real_hand_work = (SELECT SUM(8.5) FROM part_workers pw, part_worker_details pwd, phases p WHERE pwd.part_worker_id = pp.id AND pwd.worker_id = v_worker AND pw.blockweekly = 1 AND pw.cost_center_id = v_id AND pwd.phase_id = p.id AND pw.date_of_creation BETWEEN v_date_begin AND v_date_end AND p.code > '91__' GROUP BY pwd.worker_id);
        IF @real_hand_work != NULL THEN
          SET real_hand_work = real_hand_work + v_total_h/@real_hand_work*v_neto;
        END IF;
      END LOOP read_loop5pw;
      CLOSE payrollpw;
      -- part_workers
    END BLOCKPAY; 
    -- PAYROLLS
    -- SERVICIOS GENERALES REAL

    SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_consumption_cost_actual_",v_id,"_",DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%m%Y'),
      "`(`direct_cost_mo_valoriz`,`direct_cost_mo_costreal`,`direct_cost_mo_meta`,
            `direct_cost_mat_valoriz`,`direct_cost_mat_costreal`,`direct_cost_mat_meta`,
            `direct_cost_equip_valoriz`,`direct_cost_equip_costreal`,`direct_cost_equip_meta`,
            `direct_cost_subcont_valoriz`,`direct_cost_subcont_costreal`,`direct_cost_subcont_meta`,
            `direct_cost_serv_valoriz`,`direct_cost_serv_costreal`,`direct_cost_serv_meta`,
            `general_exp_mo_valoriz`, `general_exp_mo_costreal`, `general_exp_mo_meta`,
            `general_exp_mat_valoriz`,`general_exp_mat_costreal`,`general_exp_mat_meta`,
            `general_exp_subcont_valoriz`, `general_exp_subcont_costreal`, `general_exp_subcont_meta`,
            `general_exp_serv_valoriz`, `general_exp_serv_costreal`, `general_exp_serv_meta`,
            `general_exp_equip_valoriz`,`general_exp_equip_costreal`,`general_exp_equip_meta`,
            `gen_serv_mo_costreal`, `gen_serv_mo_meta`,
            `gen_serv_mat_costreal`,`gen_serv_mat_meta`,
            `gen_serv_subcont_costreal`, `gen_serv_subcont_meta`,
            `gen_serv_service_costreal`, `gen_serv_service_meta`,
            `gen_serv_equip_costreal`,`gen_serv_equip_meta`,
            `insertion_date`)
          VALUES (",
            IFNULL(val_dir_cost_hand_work,0),",", IFNULL(real_cost_hand_work,0),",", IFNULL(meta_dir_cost_hand_work,0),",",
            IFNULL(val_dir_cost_materials,0),",", IFNULL(real_cost_materials,0), ",",IFNULL(meta_dir_cost_materials,0),",",
            IFNULL(val_dir_cost_equipment,0),",", IFNULL(real_cost_equipment,0), ",",IFNULL(meta_dir_cost_equipment,0),",",
            IFNULL(val_dir_cost_subcontract,0),",", IFNULL(real_cost_subcontract,0), ",",IFNULL(meta_dir_cost_subcontract,0),",",
            IFNULL(val_dir_cost_service,0),",", IFNULL(real_cost_service,0), ",",IFNULL(meta_dir_cost_service,0),",",
            IFNULL(v_hand_work,0),",", IFNULL(r_hand_work,0), ",",IFNULL(m_hand_work,0), ",",
            IFNULL(v_materials,0), ",",IFNULL(r_materials,0), ",",IFNULL(m_materials,0), ",",
            IFNULL(v_subcontract,0), ",",IFNULL(r_subcontract,0), ",",IFNULL(m_subcontract,0), ",",
            IFNULL(v_service,0), ",",IFNULL(r_service,0), ",",IFNULL(m_service,0), ",",
            IFNULL(v_equipment,0), ",",IFNULL(r_equipment,0), ",",IFNULL(m_equipment,0),",",
            IFNULL(real_hand_work,0), ",",IFNULL(meta_hand_work,0), ",",
            IFNULL(real_materials,0), ",",IFNULL(meta_materials,0), ",",
            IFNULL(real_subcontract,0), ",",IFNULL(meta_subcontract,0), ",",
            IFNULL(real_service,0), ",",IFNULL(meta_service,0), ",",
            IFNULL(real_equipment,0), ",",IFNULL(meta_equipment,0),",","
            DATE_ADD(CURDATE(), INTERVAL -1 DAY)
            );");
    PREPARE stmt FROM @SQL;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    SET @SQLACC = CONCAT("INSERT INTO `system_bi`.`acc_consumption_cost_actual_",v_id,"_",DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%m%Y'),
      "`(`direct_cost_mo_valoriz`,`direct_cost_mo_costreal`,`direct_cost_mo_meta`,`direct_cost_mo_prog`,
            `direct_cost_mat_valoriz`,`direct_cost_mat_costreal`,`direct_cost_mat_meta`,`direct_cost_mat_prog`,
            `direct_cost_equip_valoriz`,`direct_cost_equip_costreal`,`direct_cost_equip_meta`,`direct_cost_equip_prog`,
            `direct_cost_subcont_valoriz`,`direct_cost_subcont_costreal`,`direct_cost_subcont_meta`,`direct_cost_subcont_prog`,
            `direct_cost_serv_valoriz`,`direct_cost_serv_costreal`,`direct_cost_serv_meta`,`direct_cost_serv_prog`,
            `general_exp_mo_valoriz`, `general_exp_mo_costreal`, `general_exp_mo_meta`,
            `general_exp_mat_valoriz`,`general_exp_mat_costreal`,`general_exp_mat_meta`,
            `general_exp_subcont_valoriz`, `general_exp_subcont_costreal`, `general_exp_subcont_meta`,
            `general_exp_serv_valoriz`, `general_exp_serv_costreal`, `general_exp_serv_meta`,
            `general_exp_equip_valoriz`,`general_exp_equip_costreal`,`general_exp_equip_meta`,
            `gen_serv_mo_costreal`, `gen_serv_mo_meta`,
            `gen_serv_mat_costreal`,`gen_serv_mat_meta`,
            `gen_serv_subcont_costreal`, `gen_serv_subcont_meta`,
            `gen_serv_service_costreal`, `gen_serv_service_meta`,
            `gen_serv_equip_costreal`,`gen_serv_equip_meta`,
            `insertion_date`)
          VALUES (",
            IFNULL(val_dir_cost_hand_work,0),",", IFNULL(real_cost_hand_work,0),",", IFNULL(meta_dir_cost_hand_work,0),",", IFNULL(program_cost_hand_work,0),",",
            IFNULL(val_dir_cost_materials,0),",", IFNULL(real_cost_materials,0), ",",IFNULL(meta_dir_cost_materials,0),",", IFNULL(program_cost_materials,0),",",
            IFNULL(val_dir_cost_equipment,0),",", IFNULL(real_cost_equipment,0), ",",IFNULL(meta_dir_cost_equipment,0),",", IFNULL(program_cost_equipment,0),",",
            IFNULL(val_dir_cost_subcontract,0),",", IFNULL(real_cost_subcontract,0), ",",IFNULL(meta_dir_cost_subcontract,0),",", IFNULL(program_cost_subcontract,0),",",
            IFNULL(val_dir_cost_service,0),",", IFNULL(real_cost_service,0), ",",IFNULL(meta_dir_cost_service,0),",", IFNULL(program_cost_service,0),",",
            IFNULL(v_hand_work,0),",", IFNULL(r_hand_work,0), ",",IFNULL(m_hand_work,0), ",",
            IFNULL(v_materials,0), ",",IFNULL(r_materials,0), ",",IFNULL(m_materials,0), ",",
            IFNULL(v_subcontract,0), ",",IFNULL(r_subcontract,0), ",",IFNULL(m_subcontract,0), ",",
            IFNULL(v_service,0), ",",IFNULL(r_service,0), ",",IFNULL(m_service,0), ",",
            IFNULL(v_equipment,0), ",",IFNULL(r_equipment,0), ",",IFNULL(m_equipment,0),",",
            IFNULL(real_hand_work,0), ",",IFNULL(meta_hand_work,0), ",",
            IFNULL(real_materials,0), ",",IFNULL(meta_materials,0), ",",
            IFNULL(real_subcontract,0), ",",IFNULL(meta_subcontract,0), ",",
            IFNULL(real_service,0), ",",IFNULL(meta_service,0), ",",
            IFNULL(real_equipment,0), ",",IFNULL(meta_equipment,0),",","
            DATE_ADD(CURDATE(), INTERVAL -1 DAY)
            );");
    PREPARE accvalue FROM @SQLACC;
    EXECUTE accvalue;
    DEALLOCATE PREPARE accvalue;

    SET val_dir_cost_hand_work = 0.0;
    SET val_dir_cost_materials = 0.0;
    SET val_dir_cost_equipment = 0.0;
    SET val_dir_cost_subcontract = 0.0;
    SET val_dir_cost_service = 0.0;

    SET meta_dir_cost_hand_work = 0.0;
    SET meta_dir_cost_materials = 0.0;
    SET meta_dir_cost_equipment = 0.0;
    SET meta_dir_cost_subcontract = 0.0;
    SET meta_dir_cost_service = 0.0;

    SET real_cost_hand_work = 0.0;
    SET real_cost_materials = 0.0;
    SET real_cost_equipment = 0.0;
    SET real_cost_subcontract = 0.0;
    SET real_cost_service = 0.0;

    SET program_cost_hand_work = 0.0;
    SET program_cost_materials = 0.0;
    SET program_cost_equipment = 0.0;
    SET program_cost_subcontract = 0.0;
    SET program_cost_service   = 0.0;    

    SET m_hand_work = 0.0;
    SET m_materials = 0.0;
    SET m_equipment = 0.0;
    SET m_subcontract = 0.0;
    SET m_service = 0.0;
    SET v_hand_work = 0.0;
    SET v_materials = 0.0;
    SET v_equipment = 0.0;
    SET v_subcontract = 0.0;
    SET v_service = 0.0;
    SET r_hand_work = 0.0;
    SET r_materials = 0.0;
    SET r_equipment = 0.0;
    SET r_subcontract = 0.0;
    SET r_service = 0.0;

    SET meta_hand_work = 0.0;
    SET meta_materials = 0.0;
    SET meta_equipment = 0.0;
    SET meta_subcontract = 0.0;
    SET meta_service = 0.0;

    SET real_hand_work = 0.0;
    SET real_materials = 0.0;
    SET real_equipment = 0.0;
    SET real_subcontract = 0.0;
    SET real_service = 0.0;

  END LOOP;
  CLOSE cost_centers;
END $$

DELIMITER ;
