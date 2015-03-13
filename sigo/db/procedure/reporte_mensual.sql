DELIMITER $$

DROP PROCEDURE IF EXISTS `general_services_total`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `general_services_total`()
BEGIN
  DECLARE done INT DEFAULT FALSE;

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

  DECLARE cost_centers CURSOR FOR 
    SELECT id FROM cost_centers WHERE active = 1 AND status = "A";
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

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
    BLOCKGE: BEGIN
      DECLARE donege INT DEFAULT FALSE;
      DECLARE meta CURSOR FOR 
        SELECT ged.type_article, SUM( ged.parcial ) 
        FROM general_expenses ge, general_expense_details ged
        WHERE ge.cost_center_id =1
        AND ge.id = ged.general_expense_id
        AND ge.code_phase >90
        AND DATE_FORMAT( ge.created_at,  '%Y-%m-%d' ) BETWEEN '2015-01-01' AND '2015-01-31'
        GROUP BY ged.type_article
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET donege = TRUE;
      OPEN meta;
      read_loop2: LOOP
        FETCH meta INTO v_type_article, v_amount;
        IF donege THEN
          LEAVE read_loop2;
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
        WHERE dem.cost_center_id =1
        AND dem.id = demd.diverse_expenses_of_management_id
        AND DATE_FORMAT( dem.delivered_date,  '%Y-%m-%d' ) BETWEEN '2015-01-01' AND '2015-01-31'
        GROUP BY LEFT(dem.article_code, 2)
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET donedem = TRUE;
      OPEN meta;
      read_loop2: LOOP
        FETCH meta INTO v_type_article, v_amount;
        IF donedem THEN
          LEAVE read_loop2;
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
      DECLARE stock_outputs CURSOR FOR 
        SELECT LEFT(art.code, 2), (SUM(sid.amount)*stock_output_prices.price)
        FROM stock_inputs si, stock_input_details sid, phases p, articles art,
            (SELECT art.id AS artid, ((
            pod.unit_price_igv - IFNULL( pod.discount_after, 0 ) ) * dod.amount) AS price
            FROM purchase_orders po, purchase_order_details pod, articles art, delivery_order_details dod, phases p
            WHERE po.id = pod.purchase_order_id
            AND po.cost_center_id =1
            AND pod.delivery_order_detail_id = dod.id
            AND dod.article_id = art.id
            AND po.state =  'approved'
            AND dod.phase_id = p.id
            AND p.code >  '90__'
            GROUP BY art.id) AS stock_output_prices
        WHERE si.id = sid.stock_input_id
        AND si.input = 0
        AND si.status =  'A'
        AND si.cost_center_id =1
        AND sid.article_id = art.id
        AND sid.phase_id = p.id
        AND p.code > '90__'
        AND art.id = stock_output_prices.artid
        AND DATE_FORMAT( si.issue_date,  '%Y-%m-%d' ) BETWEEN '2015-01-01' AND '2015-01-31'
        GROUP BY LEFT(art.code, 2)
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET donesi = TRUE;
      OPEN stock_outputs;
      read_loop3: LOOP
        FETCH stock_outputs INTO v_type_article, v_amount;
        IF donesi THEN
          LEAVE read_loop3;
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
      CLOSE stock_outputs;
    END BLOCKSI;

    BLOCKOS: BEGIN
      DECLARE doneos INT DEFAULT FALSE;
      DECLARE order_of_services CURSOR FOR 
        SELECT LEFT(art.code, 2), SUM(osd.unit_price_igv - IFNULL(osd.discount_after,0))
        FROM order_of_services os, order_of_service_details osd, phases p, articles art
        WHERE osd.phase_id = p.id
        AND os.id = osd.order_of_service_id
        AND os.cost_center_id =1
        AND osd.article_id = art.id
        AND p.code > '90__'
        AND os.state =  'approved'
        AND DATE_FORMAT( si.issue_date,  '%Y-%m-%d' ) BETWEEN '2015-01-01' AND '2015-01-31'
        GROUP BY LEFT(art.code, 2)
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET doneos = TRUE;
      OPEN order_of_services;
      read_loop4: LOOP
        FETCH order_of_services INTO v_type_article, v_amount;
        IF doneos THEN
          LEAVE read_loop4;
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
        SELECT SUM(CAST(REPLACE( SUBSTRING_INDEX( aport_and_amounts, '","', 1 ) , '{"neto":"', '' ) as DECIMAL(9,2))) AS Neto
        FROM payslips p,
            (SELECT id
             FROM type_of_payslips
             WHERE name LIKE  "Adelanto%"
             AND cost_center_id = 1) AS Adelanto
        WHERE p.cost_center_id = 1
        AND DATE_FORMAT( p.last_worked_day,  '%Y-%m-%d' ) BETWEEN '2015-01-01' AND '2015-01-31'
        AND p.type_of_payslip_id NOT IN (Adelanto.id)
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET donepay = TRUE;
      OPEN payroll;
      read_loop5: LOOP
        FETCH payroll INTO v_amount;
        IF donepay THEN
          LEAVE read_loop5;
        END IF;
        SET real_hand_work = v_amount + real_hand_work;
      END LOOP;
      CLOSE payroll;       
    END BLOCKPAY;

  END LOOP;
  CLOSE cost_centers;
  INSERT INTO `actual_consumption_cost_actual_january`
    (`gen_serv_mo_costreal`, `gen_serv_mo_meta`,
    `gen_serv_mat_costreal`,`gen_serv_mat_meta`,
    `gen_serv_subcont_costreal`, `gen_serv_subcont_meta`,
    `gen_serv_service_costreal`, `gen_serv_service_meta`,
    `gen_serv_equip_meta`,`gen_serv_equip_meta`)
  VALUES (real_hand_work, meta_hand_work, 
    real_materials, meta_materials, 
    real_subcontract, meta_subcontract, 
    real_service, meta_service, 
    real_equipment, meta_equipment );
END $$

DELIMITER ;