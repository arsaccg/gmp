DELIMITER $$

DROP PROCEDURE IF EXISTS `general_expenses_and_general_services_total`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `general_expenses_and_general_services_total`()
BEGIN
  DECLARE done INT DEFAULT FALSE;

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

    BLOCK5: BEGIN
      DECLARE done5 INT DEFAULT FALSE;
      DECLARE payroll CURSOR FOR 
        SELECT IFNULL(SUM(CAST(REPLACE( SUBSTRING_INDEX( aport_and_amounts, '","', 1 ) , '{"neto":"', '' ) as DECIMAL(9,2))),0) AS Neto
        FROM payslips p,
           (SELECT id
            FROM type_of_payslips
            WHERE name LIKE  "Adelanto%"
            AND cost_center_id = v_id) AS Adelanto
        WHERE p.cost_center_id = v_id
        AND p.type_of_payslip_id NOT IN (Adelanto.id)
        AND DATE_FORMAT( p.created_at,  '%Y-%m-%d' ) BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY);
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done5 = TRUE;
      OPEN payroll;
      read_loop5: LOOP
        FETCH payroll INTO v_amount;
        IF done5 THEN
          LEAVE read_loop5;
        END IF;
        SET r_hand_work = v_amount + r_hand_work;
      END LOOP;
      CLOSE payroll;       
    END BLOCK5;

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

    BLOCKPAY: BEGIN
      DECLARE donepay INT DEFAULT FALSE;
      DECLARE payroll CURSOR FOR 
        SELECT IFNULL(SUM(CAST(REPLACE( SUBSTRING_INDEX( aport_and_amounts, '","', 1 ) , '{"neto":"', '' ) as DECIMAL(9,2))),0) AS Neto
        FROM payslips p,
           (SELECT id
            FROM type_of_payslips
            WHERE name LIKE  "Adelanto%"
            AND cost_center_id = v_id) AS Adelanto
        WHERE p.cost_center_id = v_id
        AND p.type_of_payslip_id NOT IN (Adelanto.id)
        AND DATE_FORMAT( p.created_at,  '%Y-%m-%d' ) BETWEEN CONCAT(DATE_FORMAT( DATE_ADD(CURDATE(), INTERVAL -1 DAY),  '%Y-%m' ), "-01" ) AND DATE_ADD(CURDATE(), INTERVAL -1 DAY);        
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET donepay = TRUE;
      OPEN payroll;
      read_loop11: LOOP
        FETCH payroll INTO v_amount;
        IF donepay THEN
          LEAVE read_loop11;
        END IF;
        SET real_hand_work = v_amount + real_hand_work;
      END LOOP;
      CLOSE payroll;       
    END BLOCKPAY; 

    SET @SQL = CONCAT("INSERT INTO `system_bi`.`actual_consumption_cost_actual_",v_id,"_",DATE_FORMAT(DATE_ADD(CURDATE(),INTERVAL -1 DAY),'%m%Y'),
      "`(`general_exp_mo_valoriz`, `general_exp_mo_costreal`, `general_exp_mo_meta`,
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
            IFNULL(v_hand_work,0),",", IFNULL(r_hand_work,0), ",",IFNULL(m_hand_work,0), 
            ",",IFNULL(v_materials,0), ",",IFNULL(r_materials,0), ",",IFNULL(m_materials,0), 
            ",",IFNULL(v_subcontract,0), ",",IFNULL(r_subcontract,0), ",",IFNULL(m_subcontract,0), 
            ",",IFNULL(v_service,0), ",",IFNULL(r_service,0), ",",IFNULL(m_service,0), 
            ",",IFNULL(v_equipment,0), ",",IFNULL(r_equipment,0), ",",IFNULL(m_equipment,0),
            ",",IFNULL(real_hand_work,0), ",",IFNULL(meta_hand_work,0), 
            ",",IFNULL(real_materials,0), ",",IFNULL(meta_materials,0), 
            ",",IFNULL(real_subcontract,0), ",",IFNULL(meta_subcontract,0), 
            ",",IFNULL(real_service,0), ",",IFNULL(meta_service,0), 
            ",",IFNULL(real_equipment,0), ",",IFNULL(meta_equipment,0),",","
            DATE_ADD(CURDATE(), INTERVAL -1 DAY)
            );");
    PREPARE stmt FROM @SQL;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;


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
