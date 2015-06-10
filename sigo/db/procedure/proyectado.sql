DELIMITER $$

DROP PROCEDURE IF EXISTS `SHOWME_MACRO_PROJECTION`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `SHOWME_MACRO_PROJECTION`(IN vi_cost_center_id INT, IN vi_start_date CHAR(10), IN vi_end_date CHAR(10))
BEGIN
  DECLARE done INT DEFAULT FALSE;

  DECLARE v_fase INT;
  DECLARE v_article_type TEXT;
  DECLARE v_consumed FLOAT(10,2);

  DECLARE v_cd_mano_obra FLOAT(10,2);
  DECLARE v_cd_material FLOAT(10,2);
  DECLARE v_cd_equipo FLOAT(10,2);
  DECLARE v_cd_subcontrato FLOAT(10,2);
  DECLARE v_cd_servicio FLOAT(10,2);

  DECLARE v_gg_mano_obra FLOAT(10,2);
  DECLARE v_gg_material FLOAT(10,2);
  DECLARE v_gg_equipo FLOAT(10,2);
  DECLARE v_gg_subcontrato FLOAT(10,2);
  DECLARE v_gg_servicio FLOAT(10,2);

  DECLARE v_sg_mano_obra FLOAT(10,2);
  DECLARE v_sg_material FLOAT(10,2);
  DECLARE v_sg_equipo FLOAT(10,2);
  DECLARE v_sg_subcontrato FLOAT(10,2);
  DECLARE v_sg_servicio FLOAT(10,2);  

  DECLARE projection CURSOR FOR 
    SELECT left(ibbit.cod_input,2), SUM( pwd.bill_of_quantitties), LEFT( wbs.fase, 2) 
    FROM part_works pw, part_work_details pwd, itembybudgets ibb, items it, inputbybudgetanditems ibbit, itembywbses ibw, wbsitems wbs
    WHERE pw.cost_center_id = vi_cost_center_id
    AND pw.date_of_creation BETWEEN  vi_start_date AND  vi_end_date
    AND pwd.part_work_id = pw.id
    AND pwd.itembybudget_id = ibb.id
    AND ibb.item_id = it.id
    AND ibbit.item_id = it.id
    AND ibb.id = ibw.itembybudget_id
    AND ibw.wbsitem_id = wbs.id
    GROUP BY left(ibbit.cod_input,2), left(wbs.fase,2)<90, left(wbs.fase,2)=90, left(wbs.fase,2)>90;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  SET v_cd_mano_obra = 0.0;
  SET v_cd_material = 0.0;
  SET v_cd_equipo = 0.0;
  SET v_cd_subcontrato = 0.0;
  SET v_cd_servicio = 0.0;
  SET v_gg_mano_obra = 0.0;
  SET v_gg_material = 0.0;
  SET v_gg_equipo = 0.0;
  SET v_gg_subcontrato = 0.0;
  SET v_gg_servicio = 0.0;
  SET v_sg_mano_obra = 0.0;
  SET v_sg_material = 0.0;
  SET v_sg_equipo = 0.0;
  SET v_sg_subcontrato = 0.0;
  SET v_sg_servicio = 0.0;  
  OPEN projection;
  read_loop: LOOP
    FETCH projection INTO v_article_type, v_consumed, v_fase;
    IF done THEN
      LEAVE read_loop;
    END IF;
    IF v_fase < 90 THEN
      IF v_article_type = "01" THEN
        SET v_cd_mano_obra = v_consumed;
      ELSEIF v_article_type = "02" THEN
        SET v_cd_material = v_consumed;
      ELSEIF v_article_type = "03" THEN
        SET v_cd_equipo = v_consumed;
      ELSEIF v_article_type = "04" THEN
        SET v_cd_subcontrato = v_consumed;
      ELSEIF v_article_type = "05" THEN
        SET v_cd_servicio = v_consumed;
      END IF;
    ELSEIF v_fase = 90 THEN
      IF v_article_type = "01" THEN
        SET v_gg_mano_obra = v_consumed;
      ELSEIF v_article_type = "02" THEN
        SET v_gg_material = v_consumed;
      ELSEIF v_article_type = "03" THEN
        SET v_gg_equipo = v_consumed;
      ELSEIF v_article_type = "04" THEN
        SET v_gg_subcontrato = v_consumed;
      ELSEIF v_article_type = "05" THEN
        SET v_gg_servicio = v_consumed;
      END IF;    
    ELSEIF v_fase > 90 THEN
      IF v_article_type = "01" THEN
        SET v_sg_mano_obra = v_consumed;
      ELSEIF v_article_type = "02" THEN
        SET v_sg_material = v_consumed;
      ELSEIF v_article_type = "03" THEN
        SET v_sg_equipo = v_consumed;
      ELSEIF v_article_type = "04" THEN
        SET v_sg_subcontrato = v_consumed;
      ELSEIF v_article_type = "05" THEN
        SET v_sg_servicio = v_consumed;
      END IF;
    END IF;
  END LOOP;
  CLOSE projection;
  SET @SQL = CONCAT("INSERT INTO `system_bi`.`projection_macro_",vi_cost_center_id,
    "`(`cd_mano_obra`, `cd_material`, `cd_equipo`, `cd_subcontrato`, `cd_servicio`, 
       `gg_mano_obra`, `gg_material`, `gg_equipo`, `gg_subcontrato`, `gg_servicio`,
       `sg_mano_obra`, `sg_material`, `sg_equipo`, `sg_subcontrato`, `sg_servicio`,
       `insertion_date`)
      VALUES (
        '",v_cd_mano_obra,"','" ,v_cd_material,"','" ,v_cd_equipo,"','" ,v_cd_subcontrato,"','" ,v_cd_servicio,"','"
          ,v_gg_mano_obra,"','" ,v_gg_material,"','" ,v_gg_equipo,"','" ,v_gg_subcontrato,"','" ,v_gg_servicio,"','"
          ,v_sg_mano_obra,"','" ,v_sg_material,"','" ,v_sg_equipo,"','" ,v_sg_subcontrato,"','" ,v_sg_servicio,"',
          DATE_FORMAT('",vi_end_date,"','%Y-%m-%d'));");
  PREPARE stmt FROM @SQL;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;             

END $$

DELIMITER ;