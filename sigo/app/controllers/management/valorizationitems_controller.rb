class Management::ValorizationitemsController < ApplicationController
	#before_filter :authorize_manager
  	before_filter :authenticate_user!

	def update_valorization_item
		valorization = Valorization.find(params[:id])

		measured_param = params[:measured]

		item = Itembybudget.find(params[:item])

		valorization_item = Valorizationitem.where("valorization_id = ? AND itembybudget_id = ?", valorization.id, item.id).first

		if valorization_item != nil 
			valorization_item.actual_measured = measured_param
			valorization_item.save

			str_date = valorization.valorization_date.strftime("%Y-%m-%d  %T")
		    item_amount = ActiveRecord::Base.connection.execute("SELECT get_amount_acumulated('#{item.order}', '#{valorization.budget_id}', '#{str_date}', '#{valorization.id}')").first[0]
			valorization_item.accumulated_measured = item_amount / item.price
			valorization_item.save
		else
			new_valorization_item = Valorizationitem.new
			new_valorization_item.valorization_id = valorization.id
			new_valorization_item.itembybudget_id = item.id
			new_valorization_item.actual_measured = measured_param
			new_valorization_item.save

			str_date = valorization.valorization_date.strftime("%Y-%m-%d  %T")
		    item_amount = ActiveRecord::Base.connection.execute("SELECT get_amount_acumulated('#{item.order}', '#{valorization.budget_id}', '#{str_date}', '#{valorization.id}')").first[0]
			new_valorization_item.accumulated_measured = item_amount / item.price
			new_valorization_item.save
		end

		

		render nothing: true
	end

end
