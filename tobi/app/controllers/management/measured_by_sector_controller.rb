class Management::MeasuredBySectorController < ApplicationController

  def update_sector
  	exist_item = MeasuredBySector.where("sector_id = ? AND item_id = ? AND cost_center_id", params[:sector_id], params[:item_id], params[:cost_center_id]).first
  	if exist_item.count > 0
  		# Si existe
  		exist_item.sector_id = params[:sector_id]
  		exist_item.item_id = params[:item_id]

  		exist_item.save

  	else

  		MeasuredBySector.create({sector_id: params[:sector_id], item_id: params[:item_id], cost_center_id: params[:cost_center_id]})

  	end

  	render false
  end

end
