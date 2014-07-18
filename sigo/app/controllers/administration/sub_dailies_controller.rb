class Administration::SubDailiesController < ApplicationController
  def index
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def import
  end

  private
  def sub_daily_parameters
    params.require(:sub_daily).permit!
  end
end
