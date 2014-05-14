SELECT  itembybudgets.id, 
		valorizationitems.id , 
		subbudgetdetail, 
		'UND', price, measured, 
		(price * measured) AS 'total', 
		IFNULL(get_prev_valorizations(valorizations.created_at, itembybudgets.id), 0) AS 'metrado_acumulado_anterior', 
		IFNULL((get_prev_valorizations(valorizations.created_at, itembybudgets.id) * price), 0) AS 'costo_acumulado_anterior', 
		valorizationitems.actual_measured, 
		IFNULL((valorizationitems.actual_measured * price), 0) AS 'costo_actual',
		IFNULL((get_prev_valorizations(valorizations.created_at, itembybudgets.id) + valorizationitems.actual_measured), 0) as 'metrado acumulado', 
		IFNULL((get_prev_valorizations(valorizations.created_at, itembybudgets.id) + valorizationitems.actual_measured) * price, 0) as 'costo acumulado',
		IFNULL(measured - (get_prev_valorizations(valorizations.created_at, itembybudgets.id) + valorizationitems.actual_measured), 0) AS 'saldo_metrado', 
		IFNULL((measured - (get_prev_valorizations(valorizations.created_at, itembybudgets.id) + valorizationitems.actual_measured)) * price, 0) AS 'saldo_costo',
		IFNULL(((get_prev_valorizations(valorizations.created_at, itembybudgets.id) + valorizationitems.actual_measured) / measured) * 100, 0) AS 'avance'
FROM 	`itembybudgets` LEFT JOIN
		valorizationitems ON valorizationitems.itembybudget_id = itembybudgets.id LEFT JOIN 
		valorizations ON valorizationitems.valorization_id = valorizations.id
WHERE   `order` LIKE '01%' AND valorizations.id = '1';