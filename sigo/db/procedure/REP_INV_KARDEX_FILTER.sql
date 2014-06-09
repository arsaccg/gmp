DELIMITER $$

DROP PROCEDURE IF EXISTS `REP_INV_KARDEX_FILTER`$$

CREATE PROCEDURE REP_INV_KARDEX_FILTER
(IN p_company INT, IN p_user_id INT, IN p_cost_center INT, IN p_warehouses VARCHAR(500), IN p_suppliers VARCHAR(500), IN p_responsibles VARCHAR(500), IN p_years VARCHAR(500), IN p_periods VARCHAR(500), IN p_formats VARCHAR(500), IN p_articles VARCHAR(500), IN p_moneys VARCHAR(500))
BEGIN

/* Cost Centers */
/*DELETE FROM rep_inv_cost_centers WHERE user = p_user_id;

IF  p_cost_centers = '' THEN
	INSERT INTO rep_inv_cost_centers (id, name, user, created_at)
	SELECT	 id, name, p_user_id, sysdate()
	FROM	cost_centers
	WHERE  company_id = p_company;
ELSE
	INSERT INTO rep_inv_cost_centers (id, name, user, created_at)
	SELECT	 id, name, p_user_id, sysdate()
	FROM	cost_centers
	WHERE  company_id = p_company
        AND	 p_cost_centers LIKE CONCAT('%,', id, ',%');
END IF;
*/
/* Warehouses */
DELETE FROM rep_inv_warehouses WHERE user = p_user_id;

IF  p_warehouses = '' THEN
	INSERT INTO rep_inv_warehouses (id, name, user, created_at)
	SELECT	 id, name, p_user_id, sysdate()
	FROM	warehouses
	WHERE company_id = p_company;
ELSE
	INSERT INTO rep_inv_warehouses (id, name, user, created_at)
	SELECT	 id, name, p_user_id, sysdate()
	FROM	warehouses
	WHERE  company_id = p_company
        AND	 p_warehouses LIKE CONCAT('%,', id, ',%');
END IF;

/* Suppliers */
DELETE FROM rep_inv_suppliers WHERE user = p_user_id;

IF  p_suppliers = '' THEN
	INSERT INTO rep_inv_suppliers (id, name, user, created_at)
	SELECT	 c.id, c.name, p_user_id, sysdate()
	FROM	entities_type_entities a
	INNER JOIN type_entities b ON a.type_entity_id = b.id
	INNER JOIN entities c ON a.entity_id = c.id
	WHERE b.preffix = 'P';
ELSE
	INSERT INTO rep_inv_suppliers (id, name, user, created_at)
	SELECT	 c.id, c.name, p_user_id, sysdate()
	FROM	entities_type_entities a
	INNER JOIN type_entities b ON a.type_entity_id = b.id
	INNER JOIN entities c ON a.entity_id = c.id
	WHERE b.preffix = 'P'
	  AND	p_suppliers LIKE CONCAT('%,', c.id, ',%');
END IF;

/* Responsibles */
DELETE FROM rep_inv_responsibles WHERE user = p_user_id;

IF  p_responsibles = '' THEN
	INSERT INTO rep_inv_responsibles (id, name, user, created_at)
	SELECT	 c.id, c.name, p_user_id, sysdate()
	FROM	entities_type_entities a
	INNER JOIN type_entities b ON a.type_entity_id = b.id
	INNER JOIN entities c ON a.entity_id = c.id
	WHERE b.preffix = 'T';
ELSE
	INSERT INTO rep_inv_responsibles (id, name, user, created_at)
	SELECT	 c.id, c.name, p_user_id, sysdate()
	FROM	entities_type_entities a
	INNER JOIN type_entities b ON a.type_entity_id = b.id
	INNER JOIN entities c ON a.entity_id = c.id
	WHERE b.preffix = 'T'
	  AND	p_responsibles LIKE CONCAT('%,', c.id, ',%');
END IF;

/* Years */
DELETE FROM rep_inv_years WHERE user = p_user_id;

IF  p_years = '' THEN
	INSERT INTO rep_inv_years (id, user, created_at)
	SELECT	 year,  p_user_id, sysdate()
	FROM	link_times
	GROUP BY year;
ELSE
	INSERT INTO rep_inv_years (id, user, created_at)
	SELECT	 year,  p_user_id, sysdate()
	FROM	link_times
	WHERE  p_years LIKE CONCAT('%,', year, ',%')
	GROUP BY year;
END IF;

/* Periods */
DELETE FROM rep_inv_periods WHERE user = p_user_id;

IF  p_periods = '' THEN
	INSERT INTO rep_inv_periods (id, name, user, created_at)
	SELECT	 100*year + month,  100*year + month, p_user_id, sysdate()
	FROM	link_times
	GROUP BY year, month;
ELSE
	INSERT INTO rep_inv_periods (id, name, user, created_at)
	SELECT	 100*year + month,  100*year + month, p_user_id, sysdate()
	FROM	link_times
	WHERE	 p_periods LIKE CONCAT('%,', 100*year + month, ',%')
	GROUP BY year, month;
END IF;

/* Formats */
DELETE FROM rep_inv_formats WHERE user = p_user_id;

IF  p_formats = '' THEN
	INSERT INTO rep_inv_formats (id, name, user, created_at)
	SELECT	 id, name, p_user_id, sysdate()
	FROM	formats;
ELSE
	INSERT INTO rep_inv_formats (id, name, user, created_at)
	SELECT	 id, name, p_user_id, sysdate()
	FROM	formats
	WHERE   p_formats LIKE CONCAT('%,', id, ',%');
END IF;

/* Articles */
DELETE FROM rep_inv_articles WHERE user = p_user_id;

IF  p_articles = '' THEN
	INSERT INTO rep_inv_articles (id, name, user, created_at)
	SELECT	 a.id, a.name, p_user_id, sysdate()
	FROM	articles a
	INNER JOIN type_of_articles b ON a.type_of_article_id = b.id
	WHERE b.code = '02';
ELSE
	INSERT INTO rep_inv_articles (id, name, user, created_at)
	SELECT	 a.id, a.name, p_user_id, sysdate()
	FROM	articles a
	INNER JOIN type_of_articles b ON a.type_of_article_id = b.id
	WHERE b.code = '02'
	  AND	 p_articles LIKE CONCAT('%,', a.id, ',%');
END IF;

/* Moneys */
DELETE FROM rep_inv_moneys WHERE user = p_user_id;

IF  p_moneys = '' THEN
	INSERT INTO rep_inv_moneys (id, name, user, created_at)
	SELECT	 id, name, p_user_id, sysdate()
	FROM	money;
ELSE
	INSERT INTO rep_inv_moneys (id, name, user, created_at)
	SELECT	 id, name, p_user_id, sysdate()
	FROM	money
	WHERE  p_moneys LIKE CONCAT('%,', id, ',%');
END IF;

END $$
DELIMITER ;