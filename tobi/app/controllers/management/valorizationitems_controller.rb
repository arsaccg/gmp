class Management::ValorizationitemsController < ApplicationController
	before_filter :authorize_manager

	def update_valorization_item
		valorization = Valorization.find(params[:id])

		measured_param = params[:measured]

		item = Itembybudget.find(params[:item])

		valorization_item = Valorizationitem.where("valorization_id = ? AND itembybudget_id = ?", valorization.id, item.id).first

		if valorization_item != nil 
			valorization_item.actual_measured = measured_param
			valorization_item.save
		else
			new_valorization_item = Valorizationitem.new
			new_valorization_item.valorization_id = valorization.id
			new_valorization_item.itembybudget_id = item.id
			new_valorization_item.actual_measured = measured_param
			new_valorization_item.save
		end

		render nothing: true

	end

end
