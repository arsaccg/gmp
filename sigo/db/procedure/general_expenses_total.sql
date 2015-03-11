DELIMITER $$

DROP PROCEDURE IF EXISTS `general_expenses_total`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `general_expenses_total`()
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

  DECLARE v_id INTEGER;
  DECLARE v_amount DOUBLE;
  DECLARE v_type_article TEXT;

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
        AND DATE_FORMAT( ged.created_at,  '%Y-%m-%d' ) = CURDATE( )
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
        SELECT LEFT( art.code, 2 ) AS code_article, SUM( sid.amount ) 
        FROM stock_inputs si, stock_input_details sid, articles art
        WHERE si.input = 0
        AND si.cost_center_id = v_id
        AND si.status =  'A'
        AND si.issue_date = CURDATE( ) 
        AND sid.stock_input_id = si.id
        AND sid.article_id = art.id
        GROUP BY code_article;
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done3 = TRUE;
      OPEN stock_outputs;
      read_loop3: LOOP
        FETCH stock_outputs INTO v_type_article, v_amount;
        IF done3 THEN
          LEAVE read_loop3;
        END IF;
        IF v_type_article = "01" THEN
          SET r_hand_work = v_amount;
        END IF;
        IF v_type_article = "02" THEN
          SET r_materials = v_amount;
        END IF;
        IF v_type_article = "03" THEN
          SET r_equipment = v_amount;
        END IF;        
        IF v_type_article = "04" THEN
          SET r_subcontract = v_amount;
        END IF;
        IF v_type_article = "05" THEN
          SET r_service = v_amount;
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
        AND os.date_of_service = CURDATE( ) 
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
        SELECT SUM(CAST(REPLACE( SUBSTRING_INDEX( aport_and_amounts, '","', 1 ) , '{"neto":"', '' ) as DECIMAL(9,2))) AS Neto
        FROM payslips p,
           (SELECT id
            FROM type_of_payslips
            WHERE name LIKE  "Adelanto%"
            AND cost_center_id = v_id) AS Adelanto
        WHERE p.cost_center_id = v_id
        AND p.type_of_payslip_id NOT IN (Adelanto.id)
        AND DATE_FORMAT( p.created_at,  '%Y-%m-%d' ) = CURDATE( );
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
        SELECT LEFT( im.item_code, 2 ) AS type_article, SUM( i.measured * i.price )*budget.general_expense
        FROM valorizations va, valorizationitems v, itembybudgets i, items im, 
             (SELECT b.id, b.general_expense
              FROM budgets b
              WHERE b.cost_center_id = v_id
              AND b.type_of_budget = v_id
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

  END LOOP;
  CLOSE cost_centers;
END $$

DELIMITER ;