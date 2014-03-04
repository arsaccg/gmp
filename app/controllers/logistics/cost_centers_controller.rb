class Logistics::CostCentersController < ApplicationController
  before_filter :authenticate_user!
  def index
    @costCenters = CostCenter.all
    if params[:task] == 'created' || params[:task] == 'edited'
      render layout: 'dashboard'
    else
      render layout: false
    end
  end

  def create   
  end

  def edit
  end

  def show
  end

  def update
  end

  def new
  end

  def destroy
  end
end
