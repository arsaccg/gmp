class Management::MeasuredBySectorController < ApplicationController

  def update_sector
  	exist_item = MeasuredBySector.where("sector_id = ? AND itembybudget_id = ? AND cost_center_id = ?", params[:sector_id], params[:item_id], params[:cost_center_id]).first
  	if exist_item != nil
  		exist_item.measured = params[:measured]

  		exist_item.save

  	else

  		MeasuredBySector.create({sector_id: params[:sector_id], itembybudget_id: params[:item_id], cost_center_id: params[:cost_center_id], measured: params[:measured]})

  	end

  	render :nothing => true, :status => 200, :content_type => 'text/html'
  end

end
