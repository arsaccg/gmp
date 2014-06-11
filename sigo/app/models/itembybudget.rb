load 'sqlserver/dbconnector.rb'
require 'thread'


class Itembybudget < ActiveRecord::Base

	include DBConnector

	belongs_to :item
	belongs_to :budget
	has_many :subcontract_details
	has_many :itembywbses

	def set_data(budget_id, database)
		# Cargar Partidas desde base de datos remota
		#=================================================
		# SELECT     
		#0 SubpresupuestoDetalle.CodPresupuesto, 
		#1 SubpresupuestoDetalle.CodSubpresupuesto, 
		#2 SubpresupuestoDetalle.Orden, 
		#3 SubpresupuestoDetalle.Descripcion, 
		#4 SubpresupuestoDetalle.Precio1, 
		#5 SubpresupuestoDetalle.Parcial1, 
		#6 SubpresupuestoDetalle.Metrado, 
		#7 Subpresupuesto.Descripcion AS Expr1, 
		#8 Titulo.Descripcion AS Expr2, 
		#9 Partida.codPartida AS Expr3,
		#10 Partida.Descripcion AS Expr3, 
		#12 SubpresupuestoDetalle.Unidad
		 
		# array_items_data = do_query("SELECT Sb.codpartida, Sb.Orden, Sb.Metrado, Sb.precio1, Sb.Parcial1, Sb.codsubpresupuesto as s, CodPresupuesto, T.descripcion   FROM SubpresupuestoDetalle as Sb, Titulo as T WHERE codpresupuesto = '" + budget_id + "' AND T.CodTitulo =  Sb.CodTitulo ORDER BY orden ASC")

		str_query = "SELECT     
				SubpresupuestoDetalle.CodPresupuesto, 
				SubpresupuestoDetalle.CodSubpresupuesto, 
				SubpresupuestoDetalle.Orden, 
				SubpresupuestoDetalle.Descripcion, 
				SubpresupuestoDetalle.Precio1, 
				SubpresupuestoDetalle.PropioPartida, 
				SubpresupuestoDetalle.Metrado, 
				Subpresupuesto.Descripcion AS Expr1, 
				Titulo.Descripcion AS Expr2, 
				Partida.codPartida AS codpartida, 
				Partida.Descripcion AS Expr3, 
				SubpresupuestoDetalle.Unidad
				FROM SubpresupuestoDetalle 

				INNER JOIN
				Subpresupuesto 
				ON SubpresupuestoDetalle.CodPresupuesto = Subpresupuesto.CodPresupuesto 
				AND SubpresupuestoDetalle.CodSubpresupuesto = Subpresupuesto.CodSubpresupuesto 

				INNER JOIN
				Partida 
				ON SubpresupuestoDetalle.CodPartida = Partida.CodPartida 
				AND SubpresupuestoDetalle.CodPresupuestoPartida = Partida.CodPresupuesto 
				AND SubpresupuestoDetalle.PropioPartida = Partida.PropioPartida 

				INNER JOIN Titulo 
				ON SubpresupuestoDetalle.CodTitulo = Titulo.CodTitulo

	        WHERE SubpresupuestoDetalle.codpresupuesto = '" + budget_id + "' 
	        ORDER BY SubpresupuestoDetalle.orden ASC"

	    #queue_thread = SizedQueue.new(4)
		#queue_counter = 0
		#arr_thread = []

		#thread_count = 0;

		itembybudget_buffer = Array.new

        array_items_data = do_query(str_query, {db_name: database})

		array_items_data.each do |item|
			#thread_count = thread_count + 1
        	#arr_thread[thread_count] = Thread.new {
			 	#queue_counter = queue_counter + 1
			 	#queue_thread <<  queue_counter


				budget_temp = Budget.where(:cod_budget => item[0].to_s + item[1].to_s).last
				item_temp = Item.where(:item_code => item[9]).last

				b_code = budget_temp.id rescue ""
				i_code = item_temp.id rescue ""

			 	itembybudget_buffer << Itembybudget.new(item_code: item[9], order: item[2], measured: item[6], price: item[4].to_f, owneritem: item[5].to_s, subbudget_code: item[1], budget_code: item[0], title: item[8], subbudgetdetail: item[3], budget_id: b_code.to_i, item_id: i_code.to_i )

				#if new_item.save
				#	queue_thread.pop
				#end
			#}

		end

		Itembybudget.import itembybudget_buffer

		itembybudget_buffer.each do |item|
			new_input = Inputbybudgetanditem.new
			new_input.get_inputs(item.budget_code, item.item_code, item.order, item.owneritem, database)
		end


		#arr_thread.each {|t| t.join }

	end


end
