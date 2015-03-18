
DELIMITER $$
-- COSTO DIRECTO / VALORIZADO - VENTA
DROP PROCEDURE IF EXISTS `costo_directo_valorizado_por_mes`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `costo_directo_valorizado_por_mes`()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE ibi_done INT DEFAULT FALSE;

  DECLARE real_cost_hand_work FLOAT(10,2);
  DECLARE real_cost_materials FLOAT(10,2);
  DECLARE real_cost_equipment FLOAT(10,2);
  DECLARE real_cost_subcontract FLOAT(10,2);
  DECLARE real_cost_service FLOAT(10,2);

  DECLARE v_valorization_id INT;
  DECLARE v_budget_id INT;
  DECLARE v_order CHAR(120);
  DECLARE v_description CHAR(255);
  DECLARE v_measured FLOAT(10,4);

  DECLARE valorizations CURSOR FOR
	SELECT v.id, b.id 
	FROM valorizations v, budgets b 
	WHERE b.cost_center_id = 1 -- DATO DE ENTRADA
	AND b.type_of_budget = 1
	AND b.id = v.budget_id
	AND v.valorization_date BETWEEN '2014-07-01' AND '2014-07-30'; -- DATOS DE ENTRADA
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
			SET @real_cost_hand_work = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '01%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
			SET real_cost_hand_work  = IFNULL(real_cost_hand_work, 0) + IFNULL(@real_cost_hand_work, 0);

			SET @real_cost_materials = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '02%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
			SET real_cost_materials  = IFNULL(real_cost_materials, 0) + IFNULL(@real_cost_materials, 0);

			SET @real_cost_equipment = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '03%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
			SET real_cost_equipment  = IFNULL(real_cost_equipment, 0) + IFNULL(@real_cost_equipment, 0);

			SET @real_cost_subcontract = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '04%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
			SET real_cost_subcontract  = IFNULL(real_cost_subcontract, 0) + IFNULL(@real_cost_subcontract, 0);

			SET @real_cost_service = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '05%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
			SET real_cost_service  = IFNULL(real_cost_service, 0) + IFNULL(@real_cost_service, 0);

		END IF;

	  END LOOP read_loop_ibb;
	  CLOSE itembybudgets;

	END BLOCK;
	
	-- OTROS MONTO
	-- BLOCK2: BEGIN

	-- END BLOCK2;

  END LOOP read_loop;
  CLOSE valorizations;
  
  SELECT real_cost_hand_work, real_cost_materials, real_cost_equipment, real_cost_subcontract, real_cost_service FROM DUAL;

END $$

-- COSTO DIRECTO / META
DROP PROCEDURE IF EXISTS `costo_directo_meta_por_mes`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `costo_directo_meta_por_mes`()
BEGIN
  DECLARE done INT DEFAULT FALSE;

  DECLARE real_cost_hand_work FLOAT(10,2);
  DECLARE real_cost_materials FLOAT(10,2);
  DECLARE real_cost_equipment FLOAT(10,2);
  DECLARE real_cost_subcontract FLOAT(10,2);
  DECLARE real_cost_service FLOAT(10,2);

  DECLARE v_itembybudget_id INT;
  DECLARE v_budget_id INT;
  DECLARE v_order CHAR(120);

  DECLARE itembybudgets CURSOR FOR -- ESTO SACA DATOS CON ibb.id REPETIDOS
	SELECT ibb.id, ibb.budget_id, ibb.order
	FROM part_works pw, part_work_details pwd, itembybudgets ibb
	WHERE pw.cost_center_id = 1 -- DATOS DE ENTRADA 
	AND pw.date_of_creation BETWEEN '2014-08-01' AND '2014-08-30' -- DATOS DE ENTRADA
	AND pw.id = pwd.part_work_id
	AND pwd.itembybudget_id = ibb.id;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  -- MONTOS META
  OPEN itembybudgets;
  read_loop: LOOP
    FETCH itembybudgets INTO v_itembybudget_id, v_budget_id, v_order;
	IF done THEN
      LEAVE read_loop;
    END IF;
	
	SET @i_identify = (SELECT p.id FROM itembywbses ibw, wbsitems wi, phases p WHERE ibw.wbsitem_id = wi.id AND p.code > '0___' AND p.code < '89__' AND wi.phase_id = p.id AND ibw.budget_id = v_budget_id AND ibw.order_budget LIKE v_order GROUP BY p.id);

	IF @i_identify IS NOT NULL THEN
  	  SET @real_cost_hand_work = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '01%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
	  SET real_cost_hand_work  = IFNULL(real_cost_hand_work, 0) + IFNULL(@real_cost_hand_work, 0);

	  SET @real_cost_materials = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '02%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
	  SET real_cost_materials  = IFNULL(real_cost_materials, 0) + IFNULL(@real_cost_materials, 0);

	  SET @real_cost_equipment = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '03%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
	  SET real_cost_equipment  = IFNULL(real_cost_equipment, 0) + IFNULL(@real_cost_equipment, 0);

	  SET @real_cost_subcontract = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '04%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
	  SET real_cost_subcontract  = IFNULL(real_cost_subcontract, 0) + IFNULL(@real_cost_subcontract, 0);

	  SET @real_cost_service = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '05%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
	  SET real_cost_service  = IFNULL(real_cost_service, 0) + IFNULL(@real_cost_service, 0);
	END IF;

  END LOOP read_loop;
  CLOSE itembybudgets;
  
  SELECT real_cost_hand_work, real_cost_materials, real_cost_equipment, real_cost_subcontract, real_cost_service FROM DUAL;

END $$

-- COSTO DIRECTO / COSTO REAL
DELIMITER $$
DROP PROCEDURE IF EXISTS `costo_directo_real_por_mes`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `costo_directo_real_por_mes`()
BEGIN
  DECLARE done INT DEFAULT FALSE;

  DECLARE real_cost_hand_work FLOAT(10,2);
  DECLARE real_cost_materials FLOAT(10,2);
  DECLARE real_cost_equipment FLOAT(10,2);
  DECLARE real_cost_subcontract FLOAT(10,2);
  DECLARE real_cost_service FLOAT(10,2);

  DECLARE v_amount DOUBLE;
  DECLARE v_type_article TEXT;
  DECLARE v_order CHAR(120);

  BLOCK3: BEGIN
	DECLARE done3 INT DEFAULT FALSE;
    DECLARE stock_outputs CURSOR FOR 
      SELECT LEFT( art.code, 2 ) as code_article , (SUM(pod.unit_price_igv-IFNULL(pod.discount_after,0))/SUM(dod.amount)*stock_output.amount)
      FROM articles art, purchase_orders po, purchase_order_details pod, delivery_order_details dod, phases p,
            (SELECT art.id AS article_id, SUM( sid.amount ) AS amount
            FROM stock_inputs si, stock_input_details sid, articles art
            WHERE si.input = 0
            AND si.cost_center_id = 1 -- DATA ENTRADA
            AND si.status =  'A'
            AND sid.stock_input_id = si.id
            AND si.issue_date BETWEEN '2014-08-01' AND '2014-08-30' -- DATA ENTRADA
            AND sid.article_id = art.id
            GROUP BY art.id) AS stock_output
      WHERE dod.article_id = stock_output.article_id
      AND art.id = dod.article_id
      AND dod.phase_id = p.id
      AND p.code  > '0___' AND p.code < '89__'
      AND pod.delivery_order_detail_id = dod.id
      AND po.id = pod.purchase_order_id
      AND po.cost_center_id = 1 -- DATA ENTRADA
      GROUP BY art.id;
      DECLARE CONTINUE HANDLER FOR NOT FOUND SET done3 = TRUE;
    OPEN stock_outputs;
    read_loop3: LOOP
      FETCH stock_outputs INTO v_type_article, v_amount;
      IF done3 THEN
        LEAVE read_loop3;
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
    END LOOP read_loop3;
    CLOSE stock_outputs;
  END BLOCK3;

  BLOCK4: BEGIN
    DECLARE done4 INT DEFAULT FALSE;
    DECLARE order_of_services CURSOR FOR 
      SELECT LEFT(art.code, 2), SUM(osd.unit_price_igv - IFNULL(osd.discount_after,0))
      FROM order_of_service_details osd, phases p, order_of_services os, articles art
      WHERE osd.phase_id = p.id
      AND os.id = osd.order_of_service_id
      AND os.date_of_issue BETWEEN '2014-08-01' AND '2014-08-30' -- DATA ENTRADA
      AND os.cost_center_id = 1 -- DATA ENTRADA
      AND osd.article_id = art.id
      AND p.code  > '0___' AND p.code < '89__'
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
    END LOOP read_loop4;
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
            AND cost_center_id = 1) AS Adelanto -- DATA ENTRADA
        WHERE p.cost_center_id = 1 -- DATA ENTRADA
        AND p.type_of_payslip_id NOT IN (Adelanto.id)
        AND DATE_FORMAT( p.created_at,  '%Y-%m-%d' ) BETWEEN '2014-08-01' AND '2014-08-30'; -- DATA ENTRADA
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done5 = TRUE;
      OPEN payroll;
      read_loop5: LOOP
        FETCH payroll INTO v_amount;
        IF done5 THEN
          LEAVE read_loop5;
        END IF;
        SET real_cost_hand_work = IFNULL(v_amount, 0) + IFNULL(real_cost_hand_work, 0);
      END LOOP read_loop5;
      CLOSE payroll;       
    END BLOCK5;
  
  SELECT real_cost_hand_work, real_cost_materials, real_cost_equipment, real_cost_subcontract, real_cost_service FROM DUAL;

END $$

-- COSTO DIRECTO / PROGRAMADO
DROP PROCEDURE IF EXISTS `costo_directo_programado_por_mes`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `costo_directo_programado_por_mes`()
BEGIN
  DECLARE done INT DEFAULT FALSE;

  DECLARE real_cost_hand_work FLOAT(10,2);
  DECLARE real_cost_materials FLOAT(10,2);
  DECLARE real_cost_equipment FLOAT(10,2);
  DECLARE real_cost_subcontract FLOAT(10,2);
  DECLARE real_cost_service FLOAT(10,2);

  DECLARE v_code CHAR(120);
  DECLARE v_measured FLOAT(10,2);
  DECLARE v_value FLOAT(10,2);

  DECLARE distributions CURSOR FOR -- ESTO SACA DATOS CON ibb.id REPETIDOS
	SELECT d.code as 'Code Article', d.measured as 'Amount', di.value as 'Price' 
	FROM distributions d, distribution_items di 
	WHERE di.distribution_id = d.id 
	AND di.month BETWEEN '2014-07-01' AND '2014-07-31' -- Dato de Entrada
	AND d.cost_center_id = 1; -- Dato de Entrada
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN distributions;
  read_loop: LOOP
    FETCH distributions INTO v_code, v_measured, v_value;
	IF done THEN
      LEAVE read_loop;
    END IF;
	
	IF(v_code LIKE '01%') THEN
		SET @real_cost_hand_work = IFNULL(v_measured, 0.0)*IFNULL(v_value, 0.0);
		SET real_cost_hand_work  = IFNULL(real_cost_hand_work, 0) + @real_cost_hand_work;
	END IF;
	
	IF(v_code LIKE '02%') THEN
		SET @real_cost_materials = IFNULL(v_measured, 0.0)*IFNULL(v_value, 0.0);
		SET real_cost_materials  = IFNULL(real_cost_materials, 0) + IFNULL(@real_cost_materials, 0);
	END IF;

	IF(v_code LIKE '03%') THEN
		SET @real_cost_equipment = IFNULL(v_measured, 0.0)*IFNULL(v_value, 0.0);
		SET real_cost_equipment  = IFNULL(real_cost_equipment, 0) + IFNULL(@real_cost_equipment, 0);
	END IF;

	IF(v_code LIKE '04%') THEN
		SET @real_cost_subcontract = IFNULL(v_measured, 0.0)*IFNULL(v_value, 0.0);
		SET real_cost_subcontract  = IFNULL(real_cost_subcontract, 0) + IFNULL(@real_cost_subcontract, 0);
	END IF;

	IF(v_code LIKE '05%') THEN
		SET @real_cost_service = IFNULL(v_measured, 0.0)*IFNULL(v_value, 0.0);
		SET real_cost_service  = IFNULL(real_cost_service, 0) + IFNULL(@real_cost_service, 0);
	END IF;

  END LOOP read_loop;
  CLOSE distributions;
  
  SELECT real_cost_hand_work, real_cost_materials, real_cost_equipment, real_cost_subcontract, real_cost_service FROM DUAL;

END $$