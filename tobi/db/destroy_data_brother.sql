-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `destroy_data_brother`(cod_budget TEXT)
BEGIN
	SELECT * FROM `budgets` 
	WHERE `cod_budget` LIKE CONCAT( SUBSTRING(cod_budget, 1, 7) , '%' ) 
	AND `subbudget_code` NOT LIKE '001'; 
	##OR`cod_budget` LIKE '0401009%' 
	##AND `subbudget_code` IS NULL;
END