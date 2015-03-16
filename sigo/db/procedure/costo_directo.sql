DELIMITER $$
DROP PROCEDURE IF EXISTS `costo_directo_valorizado_por_mes`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `costo_directo_valorizado_por_mes`()
BEGIN
  DECLARE done INT DEFAULT FALSE;

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

	-- OTRO MONTO
	BLOCK: BEGIN

	  DECLARE itembybudgets CURSOR FOR
		SELECT rv.order, description, con_measured FROM report_valorizations rv WHERE valorization_id = v_valorization_id AND con_measured IS NOT NULL;
	  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
	  OPEN itembybudgets;
	  read_loop_ibb: LOOP
		FETCH itembybudgets INTO v_order, v_description, v_measured;

  		SET @i_identify = (SELECT p.id FROM itembywbses ibw, wbsitems wi, phases p WHERE ibw.wbsitem_id = wi.id AND p.code > '0___' AND p.code < '89__' AND wi.phase_id = p.id AND ibw.budget_id = v_budget_id AND ibw.order_budget LIKE v_order GROUP BY p.id);

		IF @i_identify IS NOT NULL THEN
			SET @real_cost_hand_work = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '01%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
			SET real_cost_hand_work  = real_cost_hand_work + IFNULL(@real_cost_hand_work, 0);

			SET @real_cost_materials = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '02%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
			SET real_cost_materials  = real_cost_materials + IFNULL(@real_cost_materials, 0);

			SET @real_cost_equipment = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '03%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
			SET real_cost_equipment  = real_cost_equipment + IFNULL(@real_cost_equipment, 0);

			SET @real_cost_subcontract = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '04%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
			SET real_cost_subcontract  = real_cost_subcontract + IFNULL(@real_cost_subcontract, 0);

			SET @real_cost_service = (SELECT SUM( ibi.quantity * ibi.price * ib.measured ) FROM inputbybudgetanditems AS ibi, itembybudgets AS ib WHERE ibi.cod_input LIKE  '05%' AND ibi.budget_id = v_budget_id AND ib.budget_id = v_budget_id AND ibi.`order` LIKE CONCAT(v_order, '%') AND ibi.`order` LIKE CONCAT( ib.`order` ,  '%' ));
			SET real_cost_service  = real_cost_service + IFNULL(@real_cost_service, 0);

		END IF;

	  END LOOP;
	  CLOSE itembybudgets;

	END BLOCK;
	
	-- OTROS MONTO
	-- BLOCK2: BEGIN

	-- END BLOCK2;

  END LOOP;
  CLOSE valorizations;
  
  SELECT real_cost_hand_work, real_cost_materials, real_cost_equipment, real_cost_subcontract, real_cost_service FROM DUAL;

END $$