load 'sqlserver/dbconnector.rb'
require 'thread'

class Inputbybudgetanditem < ActiveRecord::Base

	include DBConnector

	belongs_to :item
	belongs_to :budget
  belongs_to :article
  
  	def get_quantity_to_get(budget_id, item_id, order, owneritem, database)
  		# TODO: Codigo para obtener el numero de registros a procesar
  	end

	def get_inputs(budget_id, item_id, order, owneritem, database, start, end)

		#0 PresupuestoPartidaDetalle.CodPartida,   
		#1 PresupuestoPartidaDetalle.CodPresupuesto,
		#2 PresupuestoPartidaDetalle.CodSubPresupuesto,     
		#3 PresupuestoPartidaDetalle.PropioPartida,   
		#4 PresupuestoPartidaDetalle.CodInsumo,   
		#5 PresupuestoPartidaDetalle.Cantidad,   
		#6 PresupuestoPartidaDetalle.Precio1,   
		#7 Insumo.codInsumo,
		#8 Insumo.descripcion
		#9 Unidad.Simbolo

		str_query = "
 
		SELECT

		PresupuestoPartidaDetalle.CodPartida,   
		PresupuestoPartidaDetalle.CodPresupuesto,   
		PresupuestoPartidaDetalle.CodSubPresupuesto,
		PresupuestoPartidaDetalle.CodPartida,   
		PresupuestoPartidaDetalle.CodInsumo,   
		SUM(PresupuestoPartidaDetalle.Cantidad),   
		AVG(PresupuestoPartidaDetalle.Precio1),   
		SubpresupuestoDetalle.orden,
		Insumo.descripcion,
		Unidad.Simbolo

		From PresupuestoPartidaDetalle   
		 LEFT JOIN Partida 

		ON partida.codpartida = PresupuestoPartidaDetalle.codpartida AND 
		partida.codpresupuesto = PresupuestoPartidaDetalle.codpresupuesto AND
		partida.Propiopartida = PresupuestoPartidaDetalle.Propiopartida
		 
		LEFT JOIN Insumo
		ON Insumo.codInsumo = PresupuestoPartidaDetalle.codInsumo 

		LEFT JOIN Unidad
		ON Insumo.CodUnidad = Unidad.CodUnidad 

		LEFT JOIN SubpresupuestoDetalle ON
		PresupuestoPartidaDetalle.CodPresupuesto = SubpresupuestoDetalle.CodPresupuesto AND
		PresupuestoPartidaDetalle.CodSubpresupuesto = SubpresupuestoDetalle.CodSubpresupuesto
		

		WHERE PresupuestoPartidaDetalle.codpresupuesto = '" + budget_id  + "'  AND

			Partida.CodPartida = '" + item_id + "'  AND partida.Propiopartida <> '99' 

			AND partida.Propiopartida = '" + owneritem.to_s + "'

			AND SubpresupuestoDetalle.orden = '" +  order + "'

			GROUP BY PresupuestoPartidaDetalle.CodPartida,   
			PresupuestoPartidaDetalle.CodPresupuesto,   
			PresupuestoPartidaDetalle.CodSubPresupuesto,   
			PresupuestoPartidaDetalle.CodInsumo, 
			SubpresupuestoDetalle.orden, 
			Insumo.descripcion, 
			Unidad.Simbolo"

		#arr_thread = []
		#thread_count = 0;
		#queue_thread = SizedQueue.new(4)
		#queue_counter = 0

		inputbybudgetanditem_buffer = Array.new

		array_items_data = do_query(str_query, {db_name: database})

		array_items_data.each do |item|
			#thread_count = thread_count + 1
			#arr_thread[thread_count] = Thread.new {
				#queue_counter = queue_counter + 1
			 	#queue_thread <<  queue_counter
				budget_temp = Budget.where(:cod_budget => item[1].to_s + item[2].to_s).last
				item_temp = Item.where(:item_code => item[0]).last

				item_temp_id =  item_temp.id rescue ""
				budget_temp_id =  budget_temp.id rescue ""

			 	 	input_new =Inputbybudgetanditem.new
					input_new.coditem = item[0]  
					input_new.cod_input = item[4] 
					input_new.quantity = item[5] 
					input_new.price = item[6]  
					input_new.subbudget_code =item[2]   
					input_new.input = item[8] 
					input_new.order = item[7] 
					input_new.unit = item[9]
					input_new.budget_id = budget_temp.id rescue nil
          a = Article.where(code: item[4]).first
          
					input_new.article_id = a.id rescue nil
					input_new.item_id = item_temp.id rescue nil

					inputbybudgetanditem_buffer << input_new
				 
				#if new_item.save
					#queue_thread.pop
				#end
			#}
		end

		Inputbybudgetanditem.import inputbybudgetanditem_buffer

		#arr_thread.each {|t| t.join }

	end

end
