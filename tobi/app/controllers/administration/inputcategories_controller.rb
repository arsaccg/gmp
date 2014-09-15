load 'sqlserver/dbconnector.rb'

load 'socket_connector/socket_connector.rb'

require 'csv'

class Administration::InputcategoriesController < ApplicationController
	before_filter :authorize_manager


	include SOCKET_CONNECTOR

	def feo_of_work
		project_id =  params[:project_id]

		@budget_sale = Budget.find(params[:budget_sale]) rescue Budget.where(:cost_center_id => project_id).last
		@budget_goal = Budget.find(params[:budget_goal]) rescue @budget_sale #Budget.where(:cost_center_id).last

		p '~~~~~~~~~~~~~~~~~~~~~~~~@budget_sale~~~~~~~~~~~~~~~~~~~~~~~'
		p @budget_sale.id
		p '~~~~~~~~~~~~~~~~~~~~~~~~@budget_goal~~~~~~~~~~~~~~~~~~~~~~~'
		p @budget_goal

		@wbsitems = Wbsitem.where(cost_center_id: project_id).order(:codewbs)
		@inputcategories = Inputcategory.all

		@data_w = Inputcategory.sum_partial_sales(@budget_sale.id.to_s, @budget_goal.id.to_s)
    	@data = Inputcategory.sum_partial_sales(@budget_sale.id.to_s, @budget_goal.id.to_s, 1)

    p @data
    p @data_w

    @data_excel = Array.new
    csv = Array.new

    csv_string = CSV.generate do |csv|
      @data_w[0].each do |key, value|
        csv << [value[0], value[1], value[2], @data_w[1][key][2]] rescue [value[0], value[1], value[2], 0]
      end
    end

    respond_to do |format|
      format.html {render :feo_of_work, :layout => false}
      format.csv { send_data csv_string }
      format.xls { send_data csv_string.to_csv(col_sep: "\t") }
    end
	end

	def get_input_detail
		category_id, budget_sale_id, budget_goal_id = params[:category_id], params[:budget_sale_id], params[:budget_goal_id]
		@input_budget_item_sale = Inputcategory.get_inputs(budget_sale_id, category_id.to_s)
		@input_budget_item_goal = Inputcategory.get_inputs(budget_goal_id, category_id.to_s)
		render :partial => 'input_detail', :layout => false
	end

	def get_input_budget_item(orderitem, budgetid, wbs = nil)
    	#SELECT input, SUM(quantity), price, cod_input, coditem FROM inputbybudgetanditems
		#WHERE `cod_input` LIKE '020205%' AND `budget_id` = 44
		#GROUP BY `coditem`
		ibi = nil	
    	orderi = '0' + orderitem + '%'
    	#ibi = Inputbybudgetanditem.where('`cod_input` LIKE (?) AND budget_id = (?)', orderi, budgetid)
    	if wbs == nil
    		ibi = Inputbybudgetanditem.select('input, SUM(quantity) as quantity, price, unit, cod_input').where('`cod_input` LIKE (?) AND budget_id = (?)', orderi, budgetid).group("cod_input")
    	else
    	  hash_inputs = Hash.new
    	  total_inputs = Inputbybudgetanditem.where('cod_input LIKE ? AND budget_id = (?)', orderi, budgetid) 
    	  total_inputs.each do |input|
    	  	if hash_inputs[input.order.to_s+input.item_id.to_s]  == nil 
    	  		hash_inputs[input.order.to_s+input.item_id.to_s] =  Array.new
	    	  end
          hash_inputs[input.order.to_s+input.item_id.to_s] << input.id
    	  end

    	  itembywbs = Itembywbs.where("wbscode LIKE ?", wbs + "%")

    	  ibi_temp = Array.new
    	  itembywbs.each do |item|
  	  	  inputs = hash_inputs[item.order_budget.to_s + item.id.to_s]
  	  	  if inputs !=nil
            inputs.each do |input|
          		ibi_temp << input.id
          	end
          end
        end
  
        ibi=Inputbybudgetanditem.select('input, SUM(quantity) as quantity, price, unit, cod_input').where("id IN (?) ", ibi_temp).group(:cod_input)
 
          
      end
      return ibi
    	
	end




	def feo_pdf
    	@budget_sale = Budget.find(params[:budget_sale])
		@budget_goal = Budget.find(params[:budget_goal])
		@inputcategories = Inputcategory.all

    	@pdf_table_array = Array.new
    	@pdf_table_array << ["Codigo", "FEO DE OBRA", "PRESUPUESTO VENTA", "PRESUPUESTO META"]
    	@pdf_table_array << ["", "", "Parcial", "Parcial"]

    	direct_cost_sale = 0
	    direct_cost_goal = 0
	    @inputcategories.each do |input|
	        if input.level_n == 0 || input.level_n == 1
	            #parcial
	            partial_v = Inputcategory.sum_partial_sales(input.category_id.to_s, @budget_sale.id)
	            direct_cost_sale = direct_cost_sale + partial_v

	            #parcial
	            partial_m = Inputcategory.sum_partial_sales(input.category_id.to_s, @budget_goal.id)
	            direct_cost_goal = direct_cost_goal + partial_m

	            if input.level_n == 0
	        		@pdf_table_array << ["", input.description, partial_v.round(4), partial_m.round(4)]
	        	else
	        		@pdf_table_array << ["", " . . "+input.description, partial_v.round(4), partial_m.round(4)]
	        	end
	        else
	            #parcial
	            partial_v = Inputcategory.sum_partial_sales(input.category_id.to_s, @budget_sale.id)
	            #parcial
	            partial_m = Inputcategory.sum_partial_sales(input.category_id.to_s, @budget_goal.id)
	        	
	        	@pdf_table_array << ["", " . . . . "+input.description, partial_v.round(4), partial_m.round(4)]
	    	end
	    end
        @pdf_table_array << ["", "COSTO DIRECTO", direct_cost_sale, direct_cost_goal]

	    puts "TABLE ARRAY"
	    p @pdf_table_array

	    render :feo_pdf, :layout => false
    end

end
