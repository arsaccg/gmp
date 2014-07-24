class Management::SectorsController < ApplicationController
  
  before_filter :authorize_manager

  def index 

  end

  def edit

  end

  def show

  end

  def update

  end

  def new

  end

  def set_sectors_by_cost_center
  	cost_center = CostCenter.find(params[:id])
  	@sectors = cost_center.sectors
  	@items = cost_center.items
  	render 'set_sector_cc', layout: false
  end



end
