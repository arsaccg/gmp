load 'sqlserver/dbconnector.rb'
require 'thread'

class Item < ActiveRecord::Base

	include DBConnector

	has_many :itemsbybudgets
	has_many :measured_by_sectors
	
	belongs_to :cost_center

	def load_items(cost_center_id, budget_id, database)
		# Cargar Partidas desde base de datos remota
		#=================================================
		#
		# SELECT
    #       CodPartida,  #0
		#  		  CodPresupuesto, #1 
		#				PropioPartida,  #2
		#				Nivel,  #3
		#				Descripcion,  #4
		#				CodUnidad #5
		# FROM          Partida  
		# WHERE 		CodPresupuesto LIKE '#ID#%'

		#queue_thread = SizedQueue.new(10)
		#queue_counter = 0
		#arr_thread = []
		#thread_count = 0
		items_buffer = Array.new
		array_items = do_query("SELECT CodPartida, CodPresupuesto, PropioPartida, Nivel, Descripcion, CodUnidad FROM Partida WHERE CodPresupuesto <> '9999999' AND CodPresupuesto LIKE '" + budget_id + "'", {db_name: database})
		array_items.each do |item|
			items_buffer << Item.new(item_code: item['CodPartida'], budget_code: item['CodPresupuesto'], description: item['Descripcion'], own_code: item['PropioPartida'], level: item['Nivel'], unity_code: item['CodUnidad'], cost_center_id: cost_center_id)
		end
		array_items = do_query("SELECT CodPartida, CodPresupuesto, PropioPartida, Nivel, Descripcion, CodUnidad FROM Partida WHERE CodPresupuesto = '9999999'", {db_name: database})
 		array_items.each do |item|
			items_buffer << Item.new(item_code: item['CodPartida'], budget_code: item['CodPresupuesto'], description: item['Descripcion'], own_code: item['PropioPartida'], level: item['Nivel'], unity_code: item['CodUnidad'], cost_center_id: cost_center_id)
		end
		Item.import items_buffer
		#arr_thread.each {|t| t.join }
	end

	def code_with_name
    	"#{description}_#{item_code}"
  	end
end
